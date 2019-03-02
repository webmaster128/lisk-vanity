use ocl::builders::ProgramBuilder;
use ocl::enums::DeviceInfo;
use ocl::flags::MemFlags;
use ocl::Buffer;
use ocl::Platform;
use ocl::{Context, Device, Kernel, Queue};

use derivation::GenerateKeyType;

fn convert_ocl_error(error: ocl::Error) -> String {
    return error.to_string();
}

fn convert_ocl_core_error(error: ocl::OclCoreError) -> String {
    return error.to_string();
}

pub struct Gpu {
    kernel: ocl::Kernel,
    result: Buffer<u8>,
    key_root: Buffer<u8>,
}

impl Gpu {
    pub fn new(
        platform_idx: usize,
        device_idx: usize,
        threads: usize,
        local_work_size: Option<usize>,
        max_address_value: u64,
        generate_key_type: GenerateKeyType,
    ) -> Result<Gpu, String> {
        let mut program_builder = ProgramBuilder::new();
        program_builder
            .src(include_str!("opencl/types.cl"))
            .src(include_str!("opencl/curve25519-constants.cl"))
            .src(include_str!("opencl/curve25519-constants2.cl"))
            .src(include_str!("opencl/curve25519.cl"))
            .src(include_str!("opencl/sha/inc_hash_functions.cl"))
            .src(include_str!("opencl/sha/sha256.cl"))
            .src(include_str!("opencl/sha/sha512.cl"))
            .src(include_str!("opencl/sha_bindings.cl"))
            .src(include_str!("opencl/bip39.cl"))
            .src(include_str!("opencl/lisk.cl"))
            .src(include_str!("opencl/entry.cl"));

        let platforms = Platform::list();
        if platforms.len() == 0 {
            return Err("No OpenCL platforms exist (check your drivers and OpenCL setup)".into());
        }
        if platform_idx >= platforms.len() {
            return Err(format!(
                "Platform index {} too large (max {})",
                platform_idx,
                platforms.len() - 1
            )
            .into());
        }

        let platform = platforms[platform_idx];
        eprintln!("GPU platform {} {}", platform.vendor()?, platform.name()?);

        let device = Device::by_idx_wrap(platform, device_idx).expect("Requested device not found");
        eprintln!(
            "Using GPU device {} {}, OpenCL {}",
            device.vendor().map_err(convert_ocl_error)?,
            device.name().map_err(convert_ocl_error)?,
            device.version().map_err(convert_ocl_core_error)?
        );
        eprintln!(
            "Address bits {}",
            device
                .info(DeviceInfo::AddressBits)
                .map_err(convert_ocl_error)?
        );
        eprintln!(
            "MaxWorkGroupSize {}",
            device
                .info(DeviceInfo::MaxWorkGroupSize)
                .map_err(convert_ocl_error)?
        );

        let context = Context::builder()
            .platform(platform)
            .devices(device.clone())
            .build()?;
        eprintln!("GPU context created.");

        let queue = Queue::new(&context, device, None)?;
        eprintln!("GPU queue created.");

        let program = program_builder.devices(device).build(&context)?;
        eprintln!("GPU program successfully compiled.");

        let result = Buffer::<u8>::builder()
            .queue(queue.clone())
            .flags(MemFlags::new().write_only())
            .len(32)
            .fill_val(0u8)
            .build()?;
        let key_root = Buffer::<u8>::builder()
            .queue(queue.clone())
            .flags(MemFlags::new().read_only().host_write_only())
            .len(32)
            .build()?;

        let gen_key_type_code: u8 = match generate_key_type {
            GenerateKeyType::LiskPassphrase => 0,
            GenerateKeyType::PrivateKey => 1,
        };

        let kernel = {
            let mut builder = Kernel::builder();
            builder
                .program(&program)
                .name("generate_pubkey")
                .queue(queue.clone())
                .global_work_size(threads)
                .arg(&result)
                .arg(&key_root)
                .arg(max_address_value)
                .arg(gen_key_type_code);
            if let Some(local_work_size) = local_work_size {
                builder.local_work_size(local_work_size);
            }
            builder.build()?
        };

        eprintln!("GPU kernel built.");

        Ok(Gpu {
            kernel,
            result,
            key_root,
        })
    }

    pub fn compute(&mut self, key_root: &[u8]) -> Result<Option<[u8; 32]>, String> {
        debug_assert!({
            let mut result = [0u8; 32];
            self.result.read(&mut result as &mut [u8]).enq()?;
            result.iter().all(|&b| b == 0)
        });

        self.key_root.write(key_root).enq()?;
        unsafe {
            self.kernel.enq()?;
        }

        let mut out = [0u8; 32];
        self.result.read(&mut out as &mut [u8]).enq()?;

        let matched = !out.iter().all(|&b| b == 0);
        if matched {
            self.result.write(&[0u8; 32] as &[u8]).enq()?;
            return Ok(Option::Some(out));
        } else {
            return Ok(Option::None);
        }
    }
}

use ocl::{Device};
use ocl::builders::DeviceSpecifier;
use ocl::builders::ProgramBuilder;
use ocl::flags::MemFlags;
use ocl::Buffer;
use ocl::Platform;
use ocl::ProQue;
use ocl::Result;

use derivation::GenerateKeyType;

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
        max_address_value: u64,
        generate_key_type: GenerateKeyType,
    ) -> Result<Gpu> {
        let mut prog_bldr = ProgramBuilder::new();
        prog_bldr
            .src(include_str!("opencl/types.cl"))
            .src(include_str!("opencl/curve25519-constants.cl"))
            .src(include_str!("opencl/curve25519-constants2.cl"))
            .src(include_str!("opencl/curve25519.cl"))
            .src(include_str!("opencl/sha2.cl"))
            .src(include_str!("opencl/bip39.cl"))
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
            ).into());
        }

        let device = Device::by_idx_wrap(platforms[platform_idx], device_idx).expect("Requested device not found");
        eprintln!("Using GPU {} {}, OpenCL {}", device.vendor()?, device.name()?, device.version()?);

        let mut pro_que = ProQue::builder()
            .prog_bldr(prog_bldr)
            .platform(platforms[platform_idx])
            .device(DeviceSpecifier::Indices(vec![device_idx]))
            .dims(64)
            .build()?;

        eprintln!("GPU program successfully compiled.");

        let result = pro_que
            .buffer_builder::<u8>()
            .flags(MemFlags::new().write_only())
            .build()?;
        let key_root = pro_que
            .buffer_builder::<u8>()
            .flags(MemFlags::new().read_only().host_write_only())
            .build()?;
        pro_que.set_dims(1);

        // Set data
        result.write(&[0u8; 32] as &[u8]).enq()?;

        let gen_key_type_code: u8 = match generate_key_type {
            GenerateKeyType::LiskPassphrase => 0,
            GenerateKeyType::PrivateKey => 1,
        };

        let kernel = pro_que
            .kernel_builder("generate_pubkey")
            .global_work_size(threads)
            .arg(&result)
            .arg(&key_root)
            .arg(max_address_value)
            .arg(gen_key_type_code)
            .build()?;

        Ok(Gpu {
            kernel,
            result,
            key_root,
        })
    }

    pub fn compute(&mut self, out: &mut [u8], key_root: &[u8]) -> Result<bool> {
        self.key_root.write(key_root).enq()?;
        debug_assert!(out.iter().all(|&b| b == 0));
        debug_assert!({
            let mut result = [0u8; 32];
            self.result.read(&mut result as &mut [u8]).enq()?;
            result.iter().all(|&b| b == 0)
        });

        unsafe {
            self.kernel.enq()?;
        }

        self.result.read(&mut *out).enq()?;
        let success = !out.iter().all(|&b| b == 0);
        if success {
            self.result.write(&[0u8; 32] as &[u8]).enq()?;
        }
        Ok(success)
    }
}

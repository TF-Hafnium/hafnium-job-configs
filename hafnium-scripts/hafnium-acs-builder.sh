#!/bin/bash

# Build ACS
cd ${WORKSPACE}/ff-a-acs
mkdir build
cd build
echo "Building ACS."
cmake ../ -G"Unix Makefiles" \
	-DCROSS_COMPILE=$CROSS_COMPILE \
	-DTARGET=tgt_tfa_fvp \
	-DPLATFORM_NS_HYPERVISOR_PRESENT=0
make

# Build Hafnium
export PATH=${WORKSPACE}/prebuilts/linux-x64/clang/bin:${WORKSPACE}/prebuilts/linux-x64/dtc:$PATH
cd ${WORKSPACE}/hafnium
echo "Building Hafnium."
make PROJECT=reference

# Build TF-A
cd ${WORKSPACE}/trusted-firmware-a
echo "Buidling TF-A."
make PLAT=fvp DEBUG=1 \
	BL33=${WORKSPACE}/ff-a-acs/build/output/vm1.bin \
	BL32=${WORKSPACE}/hafnium/out/reference/secure_aem_v8a_fvp_clang/hafnium.bin \
	SP_LAYOUT_FILE=${WORKSPACE}/ff-a-acs/platform/manifest/tgt_tfa_fvp/sp_layout.json \
	ARM_SPMC_MANIFEST_DTS=${WORKSPACE}/ff-a-acs/platform/manifest/tgt_tfa_fvp/fvp_spmc_manifest.dts \
	ARM_BL2_SP_LIST_DTS=${WORKSPACE}/ff-a-acs/platform/manifest/tgt_tfa_fvp/fvp_tb_fw_config.dts \
	ARM_ARCH_MINOR=5 BRANCH_PROTECTION=1 \
	CTX_INCLUDE_PAUTH_REGS=1 CTX_INCLUDE_EL2_REGS=1  CTX_INCLUDE_MTE_REGS=1 \
	SPD=spmd \
	all fip

echo "Finished building all targets."
cd ${WORKSPACE}

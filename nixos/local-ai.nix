{ pkgs, ... }:

{
  boot.kernelParams = [
    "ttm.pages_limit=6291456"
    "ttm.page_pool_size=6291456"
  ];

  hardware.graphics.enable = true;

  environment.systemPackages = with pkgs; [
    (llama-cpp.override { vulkanSupport = true; })
    vulkan-tools
    amdgpu_top
    ffmpeg
  ];
}

# Step 1: Build ARM64 image
git clone https://github.com/xuemian168/kuno.git
cd kuno
docker buildx create --use  # if not already using buildx
docker buildx build --platform linux/arm64 -t ictrun/kuno:arm64 --load .
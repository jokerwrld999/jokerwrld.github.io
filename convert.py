from PIL import Image
import os

def convert_to_webp(input_path, output_path, quality=80):
    try:
        # Open the image file
        with Image.open(input_path) as img:
            # Convert and save the image in WebP format
            img.convert("RGB").save(output_path, "webp", quality=quality)
        print(f"Conversion successful: {input_path} -> {output_path}")
    except Exception as e:
        print(f"Error converting {input_path}: {str(e)}")

def convert_images_in_directory(input_directory, output_directory, quality=80):
    # Create the output directory if it doesn't exist
    if not os.path.exists(output_directory):
        os.makedirs(output_directory)

    # Get a list of all files in the input directory
    files = os.listdir(input_directory)

    # Filter for image files (you may need to adjust this based on your specific use case)
    image_files = [file for file in files if file.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.gif', '.tiff'))]

    # Convert each image to WebP
    for image_file in image_files:
        input_path = os.path.join(input_directory, image_file)
        output_path = os.path.join(output_directory, os.path.splitext(image_file)[0] + ".webp")
        convert_to_webp(input_path, output_path, quality)

# Example usage:
input_directory = "assets/img/2024/posts/"
output_directory = "assets/img/2024/posts/"
convert_images_in_directory(input_directory, output_directory)

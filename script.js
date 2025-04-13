document.addEventListener('DOMContentLoaded', () => {
    const galleryGrid = document.querySelector('.gallery-grid');
    
    // Generate array of all image numbers from 510 to 895
    const imageNumbers = Array.from({ length: 386 }, (_, i) => i + 510);
    const imageNames = imageNumbers.map(num => `${num}_Dashboard.jpg`);

    console.log(`Total images to load: ${imageNames.length}`);

    // Sort the images numerically based on their filename numbers
    const sortedImageNames = imageNames.sort((a, b) => {
        const numA = parseInt(a.split('_')[0]);
        const numB = parseInt(b.split('_')[0]);
        return numA - numB;
    });

    let loadedImages = 0;
    let failedImages = 0;

    // Create and append gallery items
    sortedImageNames.forEach((imageName, index) => {
        const galleryItem = document.createElement('div');
        galleryItem.className = 'gallery-item';

        const link = document.createElement('a');
        const contestNumber = imageName.split('_')[0];
        link.href = `detail.html?contest=${contestNumber}`;
        link.className = 'gallery-link';

        const img = document.createElement('img');
        img.src = `contest_images/${imageName}`;
        img.alt = `Contest #${contestNumber}`;
        img.loading = 'lazy'; // Enable lazy loading for better performance

        // Add load success handling
        img.onload = () => {
            loadedImages++;
            console.log(`Successfully loaded image ${imageName} (${loadedImages}/${imageNames.length})`);
        };

        // Add error handling for images
        img.onerror = () => {
            failedImages++;
            console.warn(`Failed to load image: ${imageName} (Failed: ${failedImages})`);
            galleryItem.style.display = 'none'; // Hide the item if image fails to load
        };

        const caption = document.createElement('div');
        caption.className = 'image-caption';
        caption.textContent = `Contest #${contestNumber}`;

        link.appendChild(img);
        link.appendChild(caption);
        galleryItem.appendChild(link);
        galleryGrid.appendChild(galleryItem);

        // Log progress every 10 images
        if ((index + 1) % 10 === 0) {
            console.log(`Added ${index + 1} images to the gallery`);
        }
    });
});
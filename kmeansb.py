import numpy as np
import matplotlib.pyplot as plt
import matplotlib.image as mpimg
 
if __name__ == '__main__':
    # Initialize rgb pixel values for each class in kmeans using specific values
    bgr_list = [(0, 0, 255),
                 (0, 255, 0),
                 (255, 0, 0),
                 (128, 128, 255),
                 (128, 255, 128),
                 (255, 128, 128),
                 (128, 0, 255),
                 (128, 255, 0),
                 (255, 128, 0),
                 (0, 128, 255),
                 (0, 255, 128),
                 (255, 0, 128)]
    # Reading images using matplotlib library
    image = mpimg.imread('demo.jpg')
    height, width, channel = image.shape
    # show original image
    plt.figure()
    plt.subplot(3, 3, 1)
    plt.axis('off')
    plt.title('Original')
    plt.imshow(image)
    # do kmeans segmentation
    for i, k in enumerate(range(5, 13, 1)):
        # extract bgr and location features
        features = []
        for y in range(height):
            for x in range(width):
                features.append(np.concatenate((image[y, x, :] / 255, np.array([y / height, x / width])), axis=0))
        features = np.array(features)
        # initial segments center using random value in features
        kmeans_centers = features[np.random.choice(len(features), k), :]
        kmeans_centers = np.array(kmeans_centers)
        # update
        while True:
            # calculate distance matrix
            def euclidean_dist(X, Y):
                Gx = np.matmul(X, X.T)
                Gy = np.matmul(Y, Y.T)
                diag_Gx = np.reshape(np.diag(Gx), (-1, 1))
                diag_Gy = np.reshape(np.diag(Gy), (-1, 1))
                return diag_Gx + diag_Gy.T - 2 * np.matmul(X, Y.T)
            dist_matrix = []
            for start in range(0, len(features), 1000):
                dist_matrix.append(euclidean_dist(features[start:start+1000, :], kmeans_centers))
            dist_matrix = np.concatenate(dist_matrix, axis=0)
            # dist_matrix = euclidean_dist(features, kmeans_centers)
            # get seg class for each sample
            segs = np.argmin(dist_matrix, axis=1)
            # update new kmeans center
            new_kmeans_centers = []
            for j in range(k):
                new_kmeans_centers.append(np.mean(features[segs==j, :], axis=0))
            new_kmeans_centers = np.array(new_kmeans_centers)
            # calculate whether converge
            if np.mean(abs(kmeans_centers - new_kmeans_centers)) < 0.1:
                break
            else:
                kmeans_centers = new_kmeans_centers
        # assign
        segs = segs.reshape(height, width)
        seg_result = np.zeros((height, width, channel), dtype=np.uint8)
        for y in range(height):
            for x in range(width):
                seg_result[y, x, :] = bgr_list[segs[y, x]]
 
        # show kmeans result
        plt.subplot(3, 3, i+2)
        plt.title('k={}'.format(k))
        plt.axis('off')
        plt.imshow(seg_result)
        plt.savefig('result_b.jpg')
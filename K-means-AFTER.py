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
    segs_k=[] #store graphs for different k
    cent=[] #store center points
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
        t=0 #control the precision
        c=0 #runnung circles for one precison
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
            
            # calculate whether converge as small as possible
            if np.mean(abs(kmeans_centers - new_kmeans_centers)) < 0.1-0.01*t:
                t+=1
                c=0
                kmeans_centers = new_kmeans_centers
                seg_temp = segs
                if t==10: break #the least presion is 0.01
                #break
            else:
                if c==10:break #after ten times try then give up
                c+=1
                kmeans_centers = new_kmeans_centers
        cent.append(kmeans_centers)
        segs_k.append(seg_temp)
        
        segs = segs_k[i]
        segs = segs.reshape(height, width)
        seg_result = np.zeros((height, width, channel), dtype=np.uint8)
        for y in range(height):
            for x in range(width):
                seg_result[y, x, :] = bgr_list[segs[y, x]]
        plt.subplot(3, 3, i+2)
        plt.title('k={}'.format(k))
        plt.axis('off')
        plt.imshow(seg_result)
    
    #caculate the distances between every pair center points
    res_l=[]
    for a in cent:
        res=0
        for p,q in enumerate(a):
            for i,k in enumerate(a[p+1:]):
                for q1 in range(len(q)):
                    res+=(int(a[p][q1])-int(a[i][q1]))^2
        
        res/=len(a)*(len(a)-1)*len(a[0])/2
        res_l.append(res)
    #larger distance better solution
    for i in range(len(res_l)):
        if res_l[i]==max(res_l):
            best=i

    # assign
    segs = segs_k[best]
    segs = segs.reshape(height, width)
    seg_result = np.zeros((height, width, channel), dtype=np.uint8)
    for y in range(height):
        for x in range(width):
            seg_result[y, x, :] = bgr_list[segs[y, x]]

    # show kmeans result
    plt.subplot(3, 3, i+2)
    plt.title('k={} is the best situation'.format(best+5))
    plt.axis('off')
    plt.imshow(seg_result)
    plt.savefig('best_k_result.jpg')
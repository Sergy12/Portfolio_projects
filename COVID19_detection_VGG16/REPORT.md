# VGG16 Image Detection Project

## Overview
### Objective
- To implement and compare 3 deep-learning models for image detection using the VGG16 architecture. Each model uses a different image preprocessing method.
- Reduce the 3 models' training total time using GPU and optimization techniques.

### Outcome
- Achieved 95% accuracy on the validation dataset.
- Reduction of training time from 3 hours per epoch to 56 seconds per epoch.
- Implemented transfer learning for efficient model training.
- Implemented multi-thread training.
- Achiee

## Dataset
The data was obtained from the Kaggle platform; the dataset is called
[COVID-19 Radiography Database](https://www.kaggle.com/datasets/tawsifurrahman/covid19-radiography-database), which contains X-ray images divided into the categories of COVID, Lung opacity, Viral pneumonia and Normal.
### Challenges
The categories of COVID and Normal were used for the model training, with 2473 and 10192 images respectively. This difference in size impacted the models' performance. This problem was addressed using data augmentation techniques. 

## Approach
### Model architecture
The model is based on ImageNet's VGG16 pre-trained model. The top layers were removed, and a Flatten layer was added. This was followed by a dense layer with ReLU activation and, finally, an output layer with a Sigmoid activation function for binary classification.

### Data preprocessing
- The images were resized to (299, 299, 3) to match the pre-trained model.
- The image preprocessing methods CLAHE, Kalman, and Gamma Correction were efficiently implemented with CUDA; and applied to all the original datasets.
- A segmentation process using masks was applied to all preprocessed datasets.
- The dataset for each image preprocessing method was divided into train, validation, and test with a percentage of 70, 20, and 10 respectively.
- The data augmentation technique used random rotation with a 20° range limit. The augmentation was applied only to the train and validation dataset.

### Training details
Optimizer: Adam with a learning rate of 1e-3.
Loss Function: Binary Cross-Entropy.
Epochs: 40
Callbacks: Early stopping with 4 tolerance.
Multi-thread training: 3 VGG16 models using each a CLAHE, Kalman, and Gamma dataset. 
Hardware: NVIDIA L40 GPU Accelerator (48 GB VRAM).

## Results
The accuracy, precision, recall, f1-score, AUC, and confusion matrix metrics were used to test the models' performance.

Clahe Accuracy: 0.9645
Clahe Precision: 0.9909
Clahe Recall: 0.9608
Clahe F1-Score: 0.9756
Clahe AUC: 0.9932

Kalman Accuracy: 0.9624
Kalman Precision: 0.9959
Kalman Recall: 0.9529
Kalman F1-Score: 0.9739
Kalman AUC: 0.9959

Gamma Correction Accuracy: 0.9588
Gamma Correction Precision: 0.9949
Gamma Correction Recall: 0.9490
Gamma Correction F1-Score: 0.9714
Gamma Correction AUC: 0.9932

![clahe](https://github.com/user-attachments/assets/aa35f294-9677-4fcf-a32f-6b9cfb6979dd)
![Kalman](https://github.com/user-attachments/assets/48e31031-c608-4d0d-b520-ff7e7006e501)
![gamma](https://github.com/user-attachments/assets/3797ebc1-bee0-4426-b6fe-d5c2c274f244)

Sequential vs. Parallel Processing Time for Preprocessing Methods Google Colab environment

| Preprocessing Method | Sequential Time | Parallel Time |
| -------- | ------- | ------- |
| Gamma Correction | 18 min | 2 min |
| CLAHE | 31 min| 5 min |
| Kalman | 39 min | 7 min |

Comparison of Training Time and Parallelization Capabilities both environments

| Setup | Training Time (Per Epoch |
| -------- | ------- |
| Google Colab CPU (Parallel) | 3 hours |
| Google Colab GPU (Sequential) | 14 min|
| Lightning Ai CPU (Parallel) | 39 min |
| Lightning Ai GPU (Parallel) | 56 sec |

## Conclusions

The training process for all three models, corresponding to the preprocessing methods (CLAHE, Kalman, and Gamma Correlation), was successfully parallelized, leveraging the computational power of the GPU. This significantly reduced the training time, enabling faster iterations and model evaluations.

Upon evaluating the models, minimal differences in their performance metrics were observed. The three models demonstrated comparable accuracy, precision, recall, F1 scores, and AUC values. Among the three preprocessing methods, the CLAHE-based model performed marginally better, achieving an average performance score of 0.96 across the metrics.
These results suggest that while the preprocessing methods do not dramatically affect the performance of the model, CLAHE might provide a slight advantage due to its ability to enhance image contrast, potentially making key features more distinguishable for the neural network. Nonetheless, the Kalman and Gamma Correlation methods also demonstrated strong and reli-
able performance, indicating their robustness in preparing data for the image recognition task.

The use of optimization techniques, advanced training strategies, and diverse hardware resources significantly reduced the time required for both image preprocessing and model training, enhancing the overall efficiency and scalability of the workflow. 

## Technical challenges
- Initially, the project was being developed using the Google Colab environment, but the GPU provided for the free version wasn't enough to train the previous 5 models in parallel. One of the objectives was to reduce the total training time so sequential training was not an option. I solved this issue by finding the platform Lighting Ai which provided more resources for a limited time, and the project proceeded on this platform after the installation of all dependencies and the migration of the datasets. Also, the project's scope was reduced to the test of 3 models.
- Since the three image preprocessing techniques consumed too much time, all of them were parallelized in the CPU by using different numbers of threads to apply the preprocessing techniques on different images at the same time; also, each technique itself was optimized using Numba to work with the GPU available. This solution was applied before the migration of the platform using Google Colab GPU.

## Contact
For questions, reach out via [LinkedIn](https://www.linkedin.com/your-profile) or [email](sergyjoel.12@hotmail.com).


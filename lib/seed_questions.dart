const seedQuestions = <Question>[
  Question(
      order: 1,
      text:
          'A meteorologist observes that if one weather station records heavy rainfall, nearby weather stations are also likely to record similar rainfall amounts. This phenomenon is best explained by:',
      options: [
        'Temporal autocorrelation',
        'Spatial autocorrelation',
        'Random sampling',
        'Seasonal variability'
      ],
      answer: 1),
  Question(
      order: 2,
      text:
          'For an autoregressive process of order-1 if Xₜ₀ represents temperature at time t₀ and has value 20°C at a particular location. Find out the temperature Xₜ₂ for additive white noise of 0.5 and regression coefficient a=2.',
      options: ['120°C', '40.5°C', '81.5°C', '81.25°C'],
      answer: 2),
  Question(
      order: 3,
      text: 'Which of the following is true regarding stationary processes?',
      options: [
        'The noise is the simplest example of a mean stationary process',
        'For a covariance stationary process, the first two moments (mean and variance) doesn’t change over time',
        'For a covariance stationary process, the covariance of the time series with lagged values of itself is constant',
        'All the statements are TRUE.'
      ],
      answer: 3),
  Question(
      order: 4,
      text:
          'A positive sea surface temperature anomaly over the tropical ocean generally indicates:',
      options: [
        'The sea surface is cooler than its climatological average.',
        'The sea surface is warmer than its climatological average',
        'The ocean has become shallower.',
        'Ocean salinity has increased'
      ],
      answer: 1),
  Question(
      order: 5,
      text:
          'Which of the following statement(s) is/are true?\nI. Gaussian Process Regression is a non-parametric technique.\nII. Gaussian Process Regression do not attempt to identify best fit models of the data, instead they compute a posterior distribution over models.',
      options: ['I only', 'II only', 'Both I and II', 'None of these'],
      answer: 2),
  Question(
      order: 6,
      text:
          'Which of the following is NOT a component of a typical geostatistical model used for climate variables such as rainfall or temperature?',
      options: [
        'Trend (mean) component',
        'Spatially correlated process',
        'Random noise component',
        'Activation function'
      ],
      answer: 3),
  Question(
      order: 7,
      text:
          'The primary role of a covariance (kernel) function in Gaussian Process Regression is to:',
      options: [
        'Estimate the regression coefficients.',
        'Measure the similarity between input points.',
        'Normalize the input data.',
        'Compute the prediction error.'
      ],
      answer: 1),
  Question(
      order: 8,
      text:
          'Consider 5 points with respective coordinates: A(5,5), B(5,6), C(6,7), D(6,6) and E(9,10). Identify the noise point among these points using DBSCAN clustering if Eps=2 and Minpts=3',
      options: ['B(5,6)', 'E(9,10)', 'A(5,5)', 'C(6,7)'],
      answer: 1),
  Question(
      order: 9,
      text:
          'A model predicts daily air temperature using historical temperature, humidity, and solar radiation. Which of the following is/are exogenous variables?',
      options: [
        'Historical temperature only',
        'Humidity and solar radiation',
        'Future temperature values',
        'Prediction errors'
      ],
      answer: 1),
  Question(
      order: 10,
      text:
          'A weather forecasting lab wants to estimate rainfall at unobserved locations while also identifying regions where predictions are less reliable. Which machine learning technique is most suitable for this objective?',
      options: [
        'Linear Regression',
        'Gaussian Process Regression',
        'K-Means Clustering',
        'Principal Component Analysis'
      ],
      answer: 1),
  Question(
      order: 11,
      text:
          'In a Geophysical Network two events A and B with time series Vᵢ and Vⱼ respectively is said to be synchronised at time t if,',
      options: [
        '| tA-tB | < threshold',
        '| tA-tB | > threshold',
        '| tA-tB | = threshold',
        '| tA-tB | >= threshold'
      ],
      answer: 0),
  Question(
      order: 12,
      text:
          'In the context of climate networks, geophysical/geographical networks help identify:\nI. Regions whose climatic or geophysical conditions are strongly related.\nII. Teleconnections between geographically distant regions.\nIII. Causal relationships between geophysical events.\nWhich of the above statements is/are true?',
      options: ['I only', 'I and II only', 'II and III only', 'I, II and III'],
      answer: 3),
  Question(
      order: 13,
      text:
          'In a Geophysical Network the probability that two randomly chosen neighbours of any node are themselves neighbour is called as',
      options: [
        'Local/Global Clustering Coefficient',
        'Degree Distribution',
        'Centrality',
        'Area weighted connectivity'
      ],
      answer: 0),
  Question(
      order: 14,
      text: 'Identify the True Statement:',
      options: [
        'When the cause and effect relate to the same time period then it is called contemporaneous causality.',
        'Granger causality is suitable for detecting contemporaneous causality.',
        'Granger causality cannot be bidirectional.',
        'None of these.'
      ],
      answer: 0),
  Question(
      order: 15,
      text:
          'Which of the following statements is incorrect about Data Assimilation?',
      options: [
        'It is a technique whereby observational data are combined with output from a numerical model to produce an optimal estimate of the evolving state of the system',
        'Data assimilation techniques like Ensemble Kalman Filter and 4D-Var have the limitation that they can handle only linear systems.',
        'The observations are used to estimate the evolving state of the system and, in some applications, calibrate model parameters.',
        'It is used to keep updating a dynamical model with observations.'
      ],
      answer: 1),
  Question(
      order: 16,
      text:
          'Suppose the occurrence of heavy rainfall in a city follows a stationary stochastic process. If the probability of heavy rainfall on day t is 0.25, then the probability of heavy rainfall on which of the following days is also expected to be 0.25?',
      options: ['t+1', 't+2', 't+3', 'All of the above'],
      answer: 3),
  Question(
      order: 17,
      text:
          'The estimate of the length of a box is updated using the following Kalman Filter equation: x̂ₖ = x̂ₖ₋₁ + 0.5(zₖ − x̂ₖ₋₁), where the Kalman Gain is constant (K=0.5). Initially, x̂₀ = 6.0 inches. The measured lengths are 6.2, 6.6, 6.1, and 7.1 cm. What is the estimate after the 4th update?',
      options: ['6.66 inches', '6.71 inches', '6.76 inches', '7.10 inches'],
      answer: 0),
  Question(
      order: 18,
      text:
          'Which of the following is/are true about causality?\nI. Granger causality can’t be misled by confounders.\nII. The standard linear Granger non-causality test is effective only when time series are stationary.\nIII. The linear Granger causality test is implemented by fitting autoregressive models.',
      options: ['I only', 'I and II', 'I and III', 'II and III'],
      answer: 3),
  Question(
      order: 19,
      text:
          'Which of the following statements is/are true?\nI. Frechet, Weibull and Gumbel distributions are examples of extreme value distributions.\nII. Gamma distribution has an exponential right-hand tail.\nIII. Anomaly events exhibit spatial coherence but can never exhibit temporal coherence.',
      options: ['I only', 'I and II', 'I and III', 'II and III'],
      answer: 1),
  Question(
      order: 20,
      text:
          'A weather forecasting model uses 100 predictor variables. The researcher wants the model to automatically identify and remove irrelevant variables. Which regression technique is most suitable?',
      options: [
        'Linear Regression',
        'Ridge Regression',
        'Lasso Regression',
        'Logistic Regression'
      ],
      answer: 2),
  Question(
      order: 21,
      text:
          'Following a powerful cyclone, disaster management authorities need to automatically locate damaged buildings in high-resolution satellite images. The AI system should identify each building and predict its location using bounding boxes so that rescue teams can rapidly assess the extent of damage. Which approach is most appropriate for this task?',
      options: [
        'Image Classification (e.g., ResNet)',
        'Object Detection (e.g., YOLO)',
        'Image Segmentation (e.g., U-Net)',
        'Regression (e.g., Linear Regression)'
      ],
      answer: 1),
  Question(
      order: 22,
      text:
          'After analysing the marks of all students, Prof. Kumar has decided to form probabilistic clusters for the 400 students enrolled in his course. The given figure shows the distribution of student marks. Which method will be suitable for him to accomplish it?',
      options: [
        'Bayesian Network',
        'Gaussian Mixture Model',
        'K-Means clustering',
        'Hard Clustering'
      ],
      answer: 1),
  Question(
      order: 23,
      text:
          'Let X be a 4×4 matrix with each element Xᵢⱼ=(i+j), where i represents row number and j represents the column number (0<=i<=3 and 0<=j<=3). What will be the output matrix Y if we apply max-pooling on X for a block size of 2 and stride equals to 2?',
      options: [
        '[[2, 4], [4, 6]]',
        '[[1, 3], [4, 6]]',
        '[[0, 2], [2, 4]]',
        '[[6, 6], [6, 6]]'
      ],
      answer: 0),
  Question(
      order: 24,
      text:
          'When modelling long-term Earth system processes, a primary limitation of LSTM networks compared to newer architectures like Transformers is:',
      options: [
        'They cannot process daily or hourly observations.',
        'Their sequential processing limits parallelization and makes it more difficult to capture very long-range temporal dependencies.',
        'They cannot be trained on multivariate Earth system data.',
        'They require all input time series to have no missing observations.'
      ],
      answer: 1),
  Question(
      order: 25,
      text: 'Which of the following statement is false for a Bayesian Network?',
      options: [
        'Bayesian Network is a Directed Acyclic Graph.',
        'In a Bayesian Network a node can have multiple parents.',
        'The conditional distribution of the nodes does not depend on parent variables.',
        'In Bayesian Network each edge has a direction from parent node to child node.'
      ],
      answer: 2),
  Question(
      order: 26,
      text:
          'Which of the following is not a characteristic feature of earth system data?',
      options: [
        'High Dimensional',
        'Multi resolution',
        'Always Categorical',
        'Imbalanced class'
      ],
      answer: 2),
  Question(
      order: 27,
      text:
          'There is a coniferous forest in the northwest region of your study area, so you identify it by enclosing it on the map with a polygon (or with multiple polygons). Another polygon is created to encompass a wheat field, another for urban buildings, and another for water. You continue this process until you have enough features to represent a class, and all classes in your data are identified. Each grouping of features is considered a class, and the polygon that encompasses the class is a training sample. This task is an example of?',
      options: [
        'Supervised learning / Regression',
        'Supervised learning / Classification',
        'Unsupervised learning / Clustering',
        'Unsupervised learning / Classification'
      ],
      answer: 1),
  Question(
      order: 28,
      text:
          'Select the most appropriate matching. Methods: A. LSTM, B. CNN, C. Auto Encoders, D. U-Net. Tasks: P. Rainfall forecasting from historical meteorological observations; Q. Flood inundation mapping using satellite imagery and semantic segmentation; R. Compression of high-dimensional climate model outputs; S. Land-use/Land-cover classification from satellite imagery.',
      options: [
        'A–P, B–R, C–S, D–Q',
        'A–P, B–S, C–R, D–Q',
        'A–Q, B–S, C–R, D–P',
        'A–Q, B–S, C–P, D–R'
      ],
      answer: 1),
  Question(
      order: 29,
      text:
          'Which of the following statements about Boltzmann’s machine is/are true?\nI. Unlike a Deep Belief Network, Deep Boltzmann’s machines are an entirely undirected model.\nII. Connections between hidden-to-hidden layer are not allowed but between visible-to-visible layer are allowed in a Restricted Boltzmann’s machine.\nIII. Boltzmann’s machines are energy-based models',
      options: ['I', 'I and II', 'I and III', 'II and III'],
      answer: 2),
  Question(
      order: 30,
      text: 'Which of the following tasks is least suitable for an LSTM model?',
      options: [
        'Soil type classification from a single multispectral satellite image',
        'Crop yield prediction using a season-long time series of temperature, rainfall, and soil moisture',
        'Groundwater level prediction using historical groundwater levels and rainfall observations',
        'Flood forecasting using historical river discharge and rainfall observations'
      ],
      answer: 0),
  Question(
      order: 31,
      text:
          'Which of the following statements about the Intertropical Convergence Zone (ITCZ) and the Indian Summer Monsoon is correct?',
      options: [
        'The ITCZ remains stationary throughout the year.',
        'The seasonal northward migration of the ITCZ contributes to the establishment of the monsoon trough and enhanced convection over India.',
        'The ITCZ primarily influences winter rainfall over India.',
        'ITCZ suppresses the transport of moisture from the Arabian Sea.'
      ],
      answer: 1),
  Question(
      order: 32,
      text:
          'A climate scientist needs to generate high-resolution projections of future rainfall over the Western Ghats. Limited computational resources are available, but several decades of reliable historical observations exist to establish relationships between large-scale climate variables and local rainfall. Which downscaling approach is most appropriate?',
      options: [
        'Dynamical downscaling using a Regional Climate Model (RCM)',
        'Statistical downscaling using empirical relationships',
        'Ensemble Kalman Filtering',
        'Principal Component Analysis'
      ],
      answer: 1),
  Question(
      order: 33,
      text:
          'In the study [Misra S, Sarkar S, Mitra P. Statistical downscaling of precipitation using long short-term memory recurrent neural networks. Theoretical and applied climatology. 2018 Nov;134(3):1179-96.], the model used for statistical downscaling is',
      options: [
        'RNN and the results have been compared with LSTM based methods.',
        'RNN-LSTM and the results have been compared with Regression based and Deep Neural Network based methods.',
        'LSTM and the results have been compared with RNN based methods.',
        'RNN-LSTM and the results have been compared with HMM based methods.'
      ],
      answer: 1),
  Question(
      order: 34,
      text:
          'In Markov Random Field based Anomaly detection, the edge potential functions between latent variables indicates that:',
      options: [
        'The anomaly events are not spatio-temporally coherent.',
        'the anomaly events are spatio-temporally coherent.',
        'the anomaly events are spatial coherent but not temporal coherent.',
        'the anomaly events are temporal coherent but not spatial coherent.'
      ],
      answer: 1),
  Question(
      order: 35,
      text:
          'The Raman Research Laboratory has gathered data for a set of climate variables that are correlated with one another and have nonlinear dependencies on one another. The data was collected for 50 years with a temporal resolution of 24 hours. They have employed a complex spatio-temporal technique for causality detection using this data and have faced few process-level challenges in this task. Which of the following will not be considered as a process-level challenge for this study?',
      options: [
        'Autocorrelation',
        'Time delays',
        'Nonlinear dependencies',
        'Sample Size'
      ],
      answer: 3),
  Question(
      order: 36,
      text: 'Identify the False statement',
      options: [
        'Causal discovery is responsible for analysing and creating models that illustrate the relationships inherent in the data.',
        'Causal inference aims to study the possible effects of altering a given system.',
        'PC algorithm identifies causes of each variable with confounders.',
        'Granger causality works well in the presence of confounders and contemporaneous relations.'
      ],
      answer: 3),
  Question(
      order: 37,
      text:
          'In the study for the identification of the predictors of Indian monsoon [Saha M, Mitra P, Nanjundiah RS. Autoencoder-based identification of predictors of Indian monsoon. Meteorology and Atmospheric Physics. 2016 Oct;128(5):613-28.], the primary task of autoencoder is',
      options: [
        'Identifying causal relationships',
        'Identifying the temporal autocorrelations of rainfall data',
        'Dimension reduction',
        'Downscaling the outputs from a GCM model to Indian subcontinent regional model'
      ],
      answer: 2),
  Question(
      order: 38,
      text:
          'Which of the following Earth system applications is best suited to a U-Net architecture because it requires assigning a class label to every pixel in a satellite image?',
      options: [
        'Flood extent mapping from satellite imagery',
        'Cyclone track prediction from historical observations',
        'Detection and localization of buildings damaged after an earthquake from satellite imagery using bounding boxes',
        'Compression of climate model outputs'
      ],
      answer: 0),
  Question(
      order: 39,
      text: 'Identify the True statement',
      options: [
        'Granger causality detection is a conditional independence-based technique, but PC algorithm is a conditional dependence-based technique.',
        'Granger causality detection is a conditional dependence-based technique, but PC algorithm is a conditional independence-based technique.',
        'Both Granger causality detection and PC algorithm are conditional independence-based techniques.',
        'Both Granger causality detection and PC algorithm are conditional dependence-based techniques.'
      ],
      answer: 1),
  Question(
      order: 40,
      text:
          'In the study [Mitra A, Seshadri AK. Detection of spatiotemporally coherent rainfall anomalies using Markov Random Fields. Computers & geosciences. 2019 Jan 1;122:45-53], Gibbs sampling has been used for',
      options: [
        'Estimation of optimal values of latent state variables',
        'Statistical Downscaling of rainfall data',
        'Maximum likelihood estimation',
        'Identification of the spatio-temporal extended rainfall anomalies'
      ],
      answer: 0),
];
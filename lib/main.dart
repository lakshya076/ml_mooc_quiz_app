import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  runApp(const QuizApp());
}

class Question {
  const Question(
      {required this.order,
      required this.text,
      required this.options,
      required this.answer});
  final int order;
  final String text;
  final List<String> options;
  final int answer;
  Map<String, Object?> toMap() => {
        'sort_order': order,
        'question': text,
        'a': options[0],
        'b': options[1],
        'c': options[2],
        'd': options[3],
        'answer': answer
      };
  factory Question.fromMap(Map<String, Object?> row) => Question(
        order: row['sort_order'] as int,
        text: row['question'] as String,
        options: [row['a'], row['b'], row['c'], row['d']].cast<String>(),
        answer: row['answer'] as int,
      );
}

class QuestionDatabase {
  static final instance = QuestionDatabase._();
  QuestionDatabase._();
  Database? _db;
  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    final db = await openDatabase(
        p.join(await getDatabasesPath(), 'ml_mooc_questions.db'),
        version: 3, onCreate: (db, _) async {
      await db.execute(
          'CREATE TABLE questions (sort_order INTEGER PRIMARY KEY, question TEXT NOT NULL, a TEXT NOT NULL, b TEXT NOT NULL, c TEXT NOT NULL, d TEXT NOT NULL, answer INTEGER NOT NULL)');
      final batch = db.batch();
      for (final q in allSeedQuestions) {
        batch.insert('questions', q.toMap());
      }
      await batch.commit(noResult: true);
    }, onUpgrade: (db, oldVersion, _) async {
      if (oldVersion < 3) {
        final batch = db.batch();
        for (final q in additionalQuestions) {
          batch.insert('questions', q.toMap(),
              conflictAlgorithm: ConflictAlgorithm.ignore);
        }
        await batch.commit(noResult: true);
      }
    });
    return _db = db;
  }

  Future<List<Question>> all() async =>
      (await (await database).query('questions', orderBy: 'sort_order ASC'))
          .map(Question.fromMap)
          .toList();
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ML MOOC Practice',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xFF006E5B)),
            useMaterial3: true),
        home: const HomePage(),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ML MOOC Practice')),
        body: FutureBuilder<List<Question>>(
            future: QuestionDatabase.instance.all(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                            'Could not open the question database.\n\n${snapshot.error}',
                            textAlign: TextAlign.center)));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final questions = snapshot.data!;
              return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),
                        Icon(Icons.school_outlined,
                            size: 72,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 18),
                        Text('${questions.length} questions ready',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        const Text(
                            'Browse in screenshot-time order or test yourself with a shuffled quiz.',
                            textAlign: TextAlign.center),
                        const SizedBox(height: 36),
                        FilledButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        StudyPage(questions: questions))),
                            icon: const Icon(Icons.menu_book_outlined),
                            label: const Text('Browse all questions')),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        WeeksPage(questions: questions))),
                            icon: const Icon(Icons.calendar_view_week_outlined),
                            label: const Text('Browse by week')),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                            onPressed: () {
                              final shuffled = [...questions]
                                ..shuffle(Random());
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          QuizPage(questions: shuffled)));
                            },
                            icon: const Icon(Icons.shuffle),
                            label: const Text('Start random quiz')),
                        const Spacer(),
                      ]));
            }),
      );
}

class WeeksPage extends StatelessWidget {
  const WeeksPage({super.key, required this.questions});
  final List<Question> questions;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Browse by week')),
        body: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 8,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final week = index + 1;
            final weekQuestions = questions
                .where((q) => (q.order - 1) ~/ 10 + 1 == week)
                .toList();
            return Card(
                child: ListTile(
              leading: CircleAvatar(child: Text('$week')),
              title: Text('Week $week'),
              subtitle: Text('${weekQuestions.length} questions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => StudyPage(
                          questions: weekQuestions, title: 'Week $week'))),
            ));
          },
        ),
      );
}

class StudyPage extends StatefulWidget {
  const StudyPage(
      {super.key, required this.questions, this.title = 'Browse questions'});
  final List<Question> questions;
  final String title;
  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  int index = 0;
  bool reveal = false;
  @override
  Widget build(BuildContext context) {
    final q = widget.questions[index];
    return Scaffold(
      appBar: AppBar(
          title: Text(
              '${widget.title}: ${index + 1} of ${widget.questions.length}')),
      body: QuestionCard(question: q, showAnswer: reveal),
      bottomNavigationBar: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                OutlinedButton(
                    onPressed: index == 0
                        ? null
                        : () => setState(() {
                              index--;
                              reveal = false;
                            }),
                    child: const Text('Previous')),
                const Spacer(),
                TextButton(
                    onPressed: () => setState(() => reveal = !reveal),
                    child: Text(reveal ? 'Hide answer' : 'Show answer')),
                const Spacer(),
                FilledButton(
                    onPressed: index == widget.questions.length - 1
                        ? null
                        : () => setState(() {
                              index++;
                              reveal = false;
                            }),
                    child: const Text('Next')),
              ]))),
    );
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.questions});
  final List<Question> questions;
  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int index = 0;
  late final List<int?> userAnswers = List.filled(widget.questions.length, null);

  int get score {
    int count = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      if (userAnswers[i] == widget.questions[i].answer) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[index];
    final selected = userAnswers[index];
    final submitted = selected != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz ${index + 1} of ${widget.questions.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Score: $score',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: QuestionCard(
          question: q,
          selected: selected,
          showAnswer: submitted,
          onSelect: submitted
              ? null
              : (value) => setState(() {
                    userAnswers[index] = value;
                  })),
      bottomNavigationBar: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: index == 0
                        ? null
                        : () => setState(() {
                              index--;
                            }),
                    child: const Text('Previous'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: (index == widget.questions.length - 1 && !submitted)
                        ? null
                        : () {
                            if (index == widget.questions.length - 1) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ResultsPage(
                                    score: score,
                                    total: widget.questions.length,
                                  ),
                                ),
                              );
                            } else {
                              setState(() {
                                index++;
                              });
                            }
                          },
                    child: Text(index == widget.questions.length - 1
                        ? 'See results'
                        : 'Next'),
                  ),
                ],
              ))),
    );
  }
}

class ResultsPage extends StatelessWidget {
  const ResultsPage({super.key, required this.score, required this.total});
  final int score, total;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Quiz complete')),
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('$score / $total',
                      style: Theme.of(context).textTheme.displayMedium),
                  const SizedBox(height: 12),
                  const Text(
                      'Nice work — start another shuffled round whenever you are ready.'),
                  const SizedBox(height: 28),
                  FilledButton(
                      onPressed: () => Navigator.of(context)
                          .popUntil((route) => route.isFirst),
                      child: const Text('Back to home')),
                ]))),
      );
}

class QuestionCard extends StatelessWidget {
  const QuestionCard(
      {super.key,
      required this.question,
      this.selected,
      required this.showAnswer,
      this.onSelect});
  final Question question;
  final int? selected;
  final bool showAnswer;
  final ValueChanged<int>? onSelect;
  @override
  Widget build(BuildContext context) => SafeArea(
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(question.text,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(height: 1.35)),
            const SizedBox(height: 24),
            for (var i = 0; i < 4; i++)
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _Option(
                      index: i,
                      text: question.options[i],
                      selected: selected == i,
                      showAnswer: showAnswer,
                      correct: question.answer == i,
                      onTap: onSelect == null ? null : () => onSelect!(i))),
            if (showAnswer)
              Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                      selected == question.answer
                          ? 'Correct!'
                          : 'Answer: ${String.fromCharCode(65 + question.answer)}',
                      style: TextStyle(
                          color: selected == question.answer
                              ? Colors.green.shade700
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.bold))),
          ])));
}

class _Option extends StatelessWidget {
  const _Option(
      {required this.index,
      required this.text,
      required this.selected,
      required this.showAnswer,
      required this.correct,
      this.onTap});
  final int index;
  final String text;
  final bool selected, showAnswer, correct;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    Color? color;
    if (showAnswer && correct) color = Colors.green.shade100;
    if (showAnswer && selected && !correct) color = Colors.red.shade100;
    return Card(
        color: color,
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: selected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.outline),
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : null),
                          child: Text(String.fromCharCode(65 + index),
                              style: TextStyle(
                                  color: selected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : null))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(text)))
                    ]))));
  }
}

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

const allSeedQuestions = <Question>[...seedQuestions, ...additionalQuestions];

const additionalQuestions = <Question>[
  // Week 5
  Question(
      order: 41,
      text:
          '''
Which of the following statements is/are True about the study - Shaby BA, Reich BJ, Cooley D, Kaufman CG. A Markov- switching model for heat waves. The Annals of Applied Statistics. 2016 Mar;10(1):74-93.
I. The study employs a 2 - state Bayesian latent state model for modelling heat waves with interpretability as one of the objectives.
II. In the case studies of Moscow and Paris, only maximum daily temperatures have been considered, the inclusion of daily minimum temperature might had been of more interests for climate analysts.
III. One of the drawbacks of the proposed model is that the model also classifies short-lived extreme high temperature periods as it doesn't contain duration in its classification criteria.''',
      options: [
        'I and II',
        'I and III',
        'II and III',
        'All'
      ],
      answer: 0),
  Question(
      order: 42,
      text:
          'Which of the following is the most appropriate one -line summary of the work - Katzfuss M, Hammerling D, Smith RL. A Bayesian hierarchical model for climate change detection and attribution. Geophysical Research Letters. 2017 Jun 16;44(11):5720-8. )',
      options: [
        'The paper presents a Bayesian hierarchical approach to the study of climate change problem which has been conventionally attempted by Regression based methods in the past.',
        'The paper presents a Bayesian hierarchical model that addresses the open questions in regression-based climate change detection and attribution, by taking into account uncertainties related due to observations, external forcings and climate variability.',
        'The paper presents a Regression based model for detecting climate change and attribution incorporating various uncertainties in observations, missing data and climate variability in the absence of any forcing',
        'The paper presents a Bayesian hierarchical model for detecting climate change and attribution by formulating climate change as a multi variate spatial or spatio- temporal regression problem including the uncertainties in observations.'
      ],
      answer: 1),
  Question(
      order: 43,
      text:
          '''
Which of the following features makes Capsule Networks (CapsNets) a better choice over Convolutional Networks (ConvNets) for a data driven framework for extreme-causing weather patterns.
I. CapsNets use pooling layers thus runs faster than ConvNets.
II. CapsNet seek invariance rather than equivariance.
III. CapsNets are better than ConvNets for capturing the spatial relationships between key features.''',
      options: [
        'II )',
        'I and II',
        'II and III',
        'III'
      ],
      answer: 3),
  Question(
      order: 44,
      text:
          'Refer to the study - Sharma A, Mitra A, Vasan V, Govindarajan R. Spatio -temporal relationships between rainfall and convective clouds during Indian monsoon through a discrete lens. International Journal of Climatology. 2021 Feb;41(2):1351-68. In this work OLR has been used as one of the proxies to measure convective cloud cover and intuitively OLR should have a negative correlation with precipitation, but in some regions of the landmass of India, during monsoon there is no rainfall in spite of low OLR. Which regions show this type of variations in the correlation between OLR and precipitation?',
      options: [
        'North Eastern India',
        'Eastern Peninsular India',
        'Peninsular India',
        'Peninsular India except the west coast'
      ],
      answer: 3),
  Question(
      order: 45,
      text:
          'In the study - Geng YA, Li Q, Lin T, Jiang L, Xu L, Zheng D, Yao W, Lyu W, Zhang Y. Lightnet: A dual spatiotemporal encoder network model for lightning prediction. In Proceedings of the 25th ACM SIGKDD international conference on knowledge discovery & data mining 2019 Jul 25 (pp. 2439-2447)., the Lightnet model proposed for lightening prediction is based on',
      options: [
        'Simulation data from WRF',
        'Weather Observational Data',
        'Both simulation data and recent observational data',
        'Reanalysis Data'
      ],
      answer: 2),
  Question(
      order: 46,
      text:
          'In the study - Berrocal VJ, Guan Y, Muyskens A, Wang H, Reich BJ, Mulholland JA, Chang HH. A comparison of statistical and machine learning methods for creating national daily maps of ambient PM2. 5 concentration. Atmospheric Environment. 2020 Feb 1;222:117130., Statistical methods such as Universal Kriging have been reported to outperform machine learning methods for air pollution exposure assessment. Which of the following ML models could have been a better choice or more competitive against the statistical models for the task?',
      options: [
        'Logistic Regression',
        'Convolution Neural Networks',
        'LSTM',
        'Decision Tree'
      ],
      answer: 1),
  Question(
      order: 47,
      text:
          '''
Match the following, in reference to the research papers reviewed in this course.
W:  Analog Forecasting P:   Equivariance
X :  OLR Q:  Look in the past
Y :  CapsNet R:  Spatial Interpolation
Z:   Kriging S:  Cloud Cover''',
      options: [
        'W-Q,X-S,Y-P,Z-R',
        'W-Q,X-S,Y-R,Z-P',
        'W-P,X-S,Y-R,Z-Q',
        'W-Q,X-R,Y-S,Z-P'
      ],
      answer: 0),
  Question(
      order: 48,
      text:
          'In the model developed for the prediction of lightening described in the study - Geng YA, Li Q, Lin T, Jiang L, Xu L, Zheng D, Yao W, Lyu W, Zhang Y. Lightnet: A dual spatiotemporal encoder network model for lightning prediction. In Proceedings of the 25th ACM SIGKDD international conference on knowledge discovery & data mining 2019 Jul 25 (pp. 2439-2447). The most appropriate statement describing the purpose of the fusion module is',
      options: [
        'Combining WRF simulation data and recent observations to eliminate the deviations in time and space domain and the consequent biases for the prediction.',
        'Combining the WRF simulation data with a deep learning-based model output for better short-term predictions.',
        'Combining WRF features and recent observational features to improve short-term predictions',
        'Combining WRF features and recent observational features to improve short-term predictions and calibrate long-term predictions.'
      ],
      answer: 3),
  Question(
      order: 49,
      text:
          'Complete the following sentence in reference to the study - Mitra A, Apte A, Govindarajan R, Vasan V, Vadlamani S. A discrete view of the Indian monsoon to ) identify spatial patterns of rainfall. Dynamics and Statistics of the Climate System. 2018;3(1):dzy009. The authors have employed ____ based approach to identify spatial patterns for Indian Summer Monsoon rainfall considering the daily rainfall data of total ___ days from the summer monsoon period months of 8 years over 357 locations and compared the results with K -means and _____ algorithms. The study has reported that only ___ spatial patterns can represent the spatial rainfall distribution for 95% days of each monsoon season.',
      options: [
        'Graph, 122, Spectral clustering, 10',
        'Markov Random Field, 122, Spectral clustering, 8',
        'Markov Random Field, 976, Spectral clustering, 10',
        'Markov Random Field, 976, Gaussian Mixture Model, 8'
      ],
      answer: 2),
  Question(
      order: 50,
      text:
          'In reference to the study - Kathuria D, Mohanty BP, Katzfuss M. A nonstationary geostatistical framework for soil moisture prediction in the presence of surface heterogeneity. Water Resources Research. 2019 Jan;55(1):729-53., which of the following statements is/are True? (I) In traditional geostatistical models, the spatial variance/correlation of soil moisture has been assumed to be constant and recent studies have found this assumption as true. ) (II) Surface characteristics like soil texture, topography and veget ation vary the spatial variance/correlation of soil moisture and the effect of vegetation is dynamic based on stage of crop, season and time of the year.',
      options: [
        'I only',
        'II only',
        'Both',
        'None'
      ],
      answer: 1),
  // Week 6
  Question(
      order: 51,
      text:
          'The interpretation of neural networks can enable the discovery of scientifically meaningful connections within geoscientific data. In accordance to the neural network interpretations identify the False statements from the below options.',
      options: [
        'Backward optimization is a neural network interpretation technique and is also known as optimal input technique.',
        'The backward optimization method takes the reverse approach of a neural network training and it always tries to update the weight, bias and input of the network to get the optimal input.',
        'Like Backward optimization, Layer -wise Relevance Propagation is also a neural network interpretations technique.',
        'Both Backward optimization and LRP method works with pre trained neural networks whose weights and biases are frozen after training.'
      ],
      answer: 1),
  Question(
      order: 52,
      text:
          'ConvNet is a CNN based architecture used by Gagne et.al in his paper "Interpretable Deep Learning for Spatial Analysis of Severe Hailstorms".  In this study, the ConvNet model is compared with some standard machine learning approaches for predicting the probability of severe hai lstorms. Which of the following machine learning models are used in this comparison? )',
      options: [
        'Logistic Mean and SVM',
        'Logistic PCA and SVM',
        'Logistic Mean and Logistic PCA',
        'SVM and PCA'
      ],
      answer: 2),
  Question(
      order: 53,
      text:
          'Which of the following is not a limitation of YOLO?',
      options: [
        'YOLO struggles with detection of small objects that appear in groups, such as flocks of birds.',
        'YOLO struggles to generalize to objects in new or unusual aspect ratios or configuration.',
        'YOLO is less likely to predict false positives on background.',
        'YOLO gives incorrect localization.'
      ],
      answer: 2),
  Question(
      order: 54,
      text:
          'When the images are captured at many wavelengths within a single spectral band then it is called as:',
      options: [
        'Multispectral Image',
        'Hyperspectral Image',
        'Infra-red Image',
        'Visible Image'
      ],
      answer: 1),
  Question(
      order: 55,
      text:
          '''
Deep Learning architectures can be classified as two-stage, single-shot, and anchor- free architecture. Identify the perfect match between the architectures and models given below Architecture Model
(i) Two-Stage (a) YOLO \n(ii) Single-Shot (b) R-CNN \n(iii) Anchor-Free (c) Corner-Net''',
      options: [
        '(i)-(a), (ii)-(b), (iii)-(c)',
        '(i)-(c), (ii)-(b), (iii)-(a)',
        '(i)-(b), (ii)-(a), (iii)-(c)',
        '(i)-(a), (ii)-(c), (iii)-(b)'
      ],
      answer: 2),
  Question(
      order: 56,
      text:
          '''
"DOTA: A Large-scale Dataset for Object Detection in Aerial Images" is a research article by Xia et. al. To show the usefulness of DOTA in horizontal object detection the authors have evaluated some state -of-the-art object detection algorithms on DOTA. Which of the following algorithms are used in this task?
(i) Faster R-CNN     (ii)   R-FCN        (iii)    SSD       (iv)  YOLOv2''',
      options: [
        '(i) and (ii)',
        '(i), (ii) and (iii)',
        '(i), (ii), (iii) and (iv)',
        '(ii), (iii) and (iv)'
      ],
      answer: 2),
  Question(
      order: 57,
      text:
          'The CNN based method proposed by Fu et.al for Hyperspectral Image Super - Resolution (Ref: "Hyperspectral Image Super -Resolution with Optimized RGB Guidance", Fu et.al. 2019) is',
      options: [
        'A supervised method',
        'An unsupervised method',
        'A semi-supervised method',
        'Either supervised or semi-supervised method.'
      ],
      answer: 1),
  Question(
      order: 58,
      text:
          'Which of the following statement is true for a panchromatic (PAN) image?',
      options: [
        'PAN images possess high spatial resolution but low spectral resolution.',
        'PAN images possess low spatial resolution and low spectral resolution.',
        'PAN images possess high spatial resolution and high spectral resolution.',
        'PAN images possess low spatial resolution but high spectral resolution. )'
      ],
      answer: 0),
  Question(
      order: 59,
      text:
          '"SkyScapes - Fine-Grained Semantic Understanding of Aerial Scenes" is an article by Azimi et.al.(2019). From the given options identify the most appropriate option that indicates the main contribution of this work.',
      options: [
        'Preparation of an aerial image datase t with highly -accurate, fine -grained annotations for pixel-level semantic labeling.',
        'Development of a fully connected neural network for fine -grained semantic understanding of aerial scenes.',
        'Introduction of an image restoration technique for satellite images.',
        'Development of a nested image segmentation network.'
      ],
      answer: 0),
  Question(
      order: 60,
      text:
          ') RDU_Net is a novel architectur e used for Sea_Land Segmentation using remote sensing images. It is also assumed that there are some other architectures that can be employed for the same task. Which of the following networks can be used to perform the same task as RDU_Net.',
      options: [
        'Only FusionNet',
        'Only DeepUNet',
        'Both FusionNet and DeepUNet',
        'None of these'
      ],
      answer: 2),
  // Week 7
  Question(
      order: 61,
      text:
          'The normalized difference vegetation index (NDVI) is  a simple indicator of green vegetation that can be used to analyse remote sensing measurements. The NDVI value depends on the RED and NIR component of the reflected light. Which of the following formula shows the relationship between NDVI, RED and INR?',
      options: [
        'NDVI = (NIR-RED)/(NIR+RED)',
        'NDVI = (2 * NIR)/(NIR+RED)',
        'NDVI = (2 * RED)/(NIR-RED)',
        'NDVI = (NIR+RED)/(NIR-RED)'
      ],
      answer: 0),
  Question(
      order: 62,
      text:
          'To predict the PM2.5 atmospheric air pollution Muthukumar et. al. have used some advanced deep learning models with remote -sensing satellite imagery of air pollution, ground-based sensors monitoring data of air pollutants and meteorological features. Which of the following models are used in this work? [Ref: Muthukumar P, Cocom E, Nagrecha K, Comer D, Burga I, Taub J, Calvert CF, Holm J, Pourhomayoun M. Predicting PM2. 5 atmospheric air pollution using deep learning with meteorological data and ground- based observations and remote - sensing satellite big data. Air Quality, Atmosphere & Health. 2021 Nov 23:1-4.]',
      options: [
        'GCN and LSTM',
        'GCN and ConvLSTM',
        'CNN and ConvLSTM',
        'CNN and LSTM )'
      ],
      answer: 1),
  Question(
      order: 63,
      text:
          'Which of the following is a key difference between a Gated Recurrent Unit (GRU) and a Long Short-Term Memory (LSTM) network?',
      options: [
        'GRUs have fewer gates and fewer parameters than LSTMs.',
        'LSTMs do not use gating mechanisms, whereas GRUs use update and reset gates.',
        'GRUs are designed exclusively for image processing, whereas LSTMs are designed exclusively for natural language processing.',
        'LSTMs cannot capture long- term temporal dependencies, whereas GRUs can capture arbitrarily long dependencies.'
      ],
      answer: 0),
  Question(
      order: 64,
      text:
          'Convolutional LSTM(ConvLSTM) and Trajectory GRU (TrajGRU) are two deep learning architectures used for precipitation nowcasting. With respect to the said models identify the true statement from the given options: )',
      options: [
        'The convolutional structure of ConvLSTM helps it to perform better than TrajGRU in nowcasting the precipitation.',
        'Both ConvLSTM and TrajGRU are location-variant in nature.',
        'The Trajectory GRU model can actively learn the location -variant structure for recurrent connections.',
        'TrajGRU is a traditional optical flow-based method used for nowcasting.'
      ],
      answer: 2),
  Question(
      order: 65,
      text:
          'Researchers of the Earth Science Laboratory have collected a set of remote sensing data for the Indian subcontinent. They have trained and tested a deep neural network with this data. Later they tried to transfer the knowledge learned by the deep neural network on the source  task to a new related target task. Which of the following method they have used in this task?',
      options: [
        'Classification',
        'Domain Adaptation',
        'Regression',
        'Image Segmentation'
      ],
      answer: 1),
  Question(
      order: 66,
      text:
          '''
Which of the following statements is/are true for the Triplet Adversarial Domain Adaptation (TriADA) method? [Ref: Yan L, Fan B, Liu H, Huo C, Xiang S, Pan C.  Triplet adversarial domain adaptation for pixel -level classification of VHR remote sensing images. IEEE Transactions on Geoscience and Remote Sensing. 2019 Dec 30; 58(5):3558-73.]
(i) TriADA is used for Pixel-level classification of very high resolution (VHR) remote sensing images. (ii) TriADA method jointly considers both the source and target domains to learn a domain -invariant classifier by a novel domain similarity discriminator.''',
      options: [
        'Only (i)',
        'Only (ii)',
        'Both (i) and (ii)',
        'Neither (i) nor (ii)'
      ],
      answer: 2),
  Question(
      order: 67,
      text:
          '''
Which of the following statements indicates the objectives of earth system modeling?
(i) Understanding the interactions between different components of earth system. (ii) Understanding future scenarios like climate change. (iii) Estimating the occurrence of specific events like floods and earthquakes. )''',
      options: [
        '(i) and (ii)',
        '(ii) and (iii)',
        '(i) and (iii)',
        '(i), (ii) and (iii)'
      ],
      answer: 3),
  Question(
      order: 68,
      text:
          'In a typical physics-informed neural network (PINN) for solving a time-dependent partial differential equation, where are the core physics constraints most directly enforced during training?',
      options: [
        'By constraining the optimization algorithm to search only in parameter regions allowed by the physics',
        'Only at the input layer by encoding physical variables as features',
        'In the loss function through residuals of the governing differential equations evaluated at collocation points',
        'In the final output layer by post- processing the network predictions to satisfy conservation laws.'
      ],
      answer: 2),
  Question(
      order: 69,
      text:
          '''
Identify the True statement/statements from the statements given below.
(i)  Process-based Model is a mathematical model for the entire process including all variables. (ii)  Statistical Models tries to reproduce only the observable part of the process irrespective of the physics behind it.''',
      options: [
        'Only (i) is true.',
        'Both (i) and (ii) are true',
        'Only (ii) is true',
        'Both (i) and (ii) are false'
      ],
      answer: 1),
  Question(
      order: 70,
      text:
          'Fill in the blanks with reference to the article "Mitra A. Bayesian approach to Spatio-temporally Consistent Simulation of Daily Monsoon Rainfall over India. In Proceedings of the 25th ACM SIGSPATIAL International Conference on Advances in Geographic Information Systems 2017 Nov 7 (pp. 1-4)." During parameter estimation from observed data, the authors have used spatio - temporal smoothing using ___________________ so that the parameters learnt are spatially and temporally coherent. )',
      options: [
        'Markov Random Field',
        'Non parametric spatial clustering',
        'Chinese Restaurant Process',
        'LSTM'
      ],
      answer: 0),
  // Week 8
  Question(
      order: 71,
      text:
          'Match the studies in column - 1 with the machine learning models in column-2 used in that study for learning parameterization of convection. Study ML model \nS1: Model CBRAIN proposed by Gentine et.al. , 2018. \tResNet \nS2: O\'Gorman PA, Dwyer JG. Using machine learning to parameterize moist convection: Potential for modeling of climate, climate change, and extreme events. Journal of Advances in Modeling Earth Systems. 2018 Oct;10(10):2548-63. \tANN \nS3 : Han Y, Zhang GJ, Huang X, Wang Y. A moist physics parameterization based on deep learning. Journal of Advances in Modeling Earth Systems. 2020 Sep;12(9):e2020MS002076. \tRandom Forest',
      options: [
        '(S1,ResNet),(S2,ANN),(S3, Random Forest)',
        '(S1,ResNet),(S2,Random Forest), (S3,ANN)',
        '(S1,ANN), (S2,Random Forest), (S3,ResNet)',
        '(S1,ANN), (S2,ResNet), (S3,Random Forest)'
      ],
      answer: 2),
  Question(
      order: 72,
      text:
          'Which of the following is/are the justifications that even after the ready availability of three-dimensional hydrodynamical models, General Lake Model (GLM) was proposed as a one-dimensional model? \nI:  One-dimensional models easily interface with biogeochemical and ecological modelling libraries for complex ecosystem simulations. \nII:  GLM captures only the lake water balance and one-dimensional models are sufficient for this. \nIII:  One-dimensional models have lower computational requirements.',
      options: [
        'I only',
        'I and II',
        'II and III',
        'I and III'
      ],
      answer: 3),
  Question(
      order: 73,
      text:
          '''
In the study - Manepalli A, Albert A, Rhoades A, Feldman D, Jones AD. Emulating numeric hydroclimate models with physics -informed cGANs. In AGU fall meeting 2019 Dec 11., the authors have investigated upon the use of a deep generative model cGAN to simulate the output of  a physics-based model for snow water equivalent ) (SWE). Which of the following is/are the domain knowledge that have been incorporated into the deep learning model via additional penalty terms?
I. SWE increases with altitude
II. Seasonal variations in SWE
III. Known portions of data that have no SWE''',
      options: [
        'I and II',
        'I and III',
        'II and III',
        'All'
      ],
      answer: 1),
  Question(
      order: 74,
      text:
          'In the study - Read JS, Jia X, Willard J, Appling AP, Zwart JA, Oliver SK, Karpatne A, Hansen G J, Hanson PC, Watkins W, Steinbach M. Process -guided deep learning predictions of lake water temperature. Water Resources Research. 2019 Nov;55(11):9173-90., the authors experimented with 3 models (Process Based Model, Deep Learning based empirical only model and Process - Guided Deep Learning model) to predict the lake temperatures for lake Mendota. Which of the following models suffered the most loss in accuracy when the amount of training data was artificially reduced?',
      options: [
        'Process based Model.',
        'Deep Learning based empirical only model.',
        'Process-Guided Deep Learning Model',
        'Deep Learning based empirical only models and Process-Guided Deep Learning Models suffered the same loss of accuracy. )'
      ],
      answer: 0),
  Question(
      order: 75,
      text:
          'Which one of the following is generally not considered a limitation of process- based Earth system models?',
      options: [
        'Requirement of Model Calibration',
        'Representation of unresolved processes through sub-grid parameterization',
        'High computational cost',
        'Use of physics-based governing equations'
      ],
      answer: 3),
  Question(
      order: 76,
      text:
          ') In the study - Chen L, Fang B, Zhao L, Zang Y, Liu W, Chen Y, Wang C, Li J. DeepUrbanDownscale: A physics informed deep learning framework for high- resolution urban surface temperature estimation via 3D point clouds. International Journal of Applied Earth Observation and Geoinformation. 2022 Feb 1;106:102650., the role of the descriptor Local Spatial Coefficient Index (LSCI) is best described as',
      options: [
        'To aggregate the potential factors that influence the local -scale urban surface temperature.',
        'To incorporate the heterogeneity of the urban surface (water, building, vegetation, soil).',
        'To map the 3-D point cloud of the local region into the deep learning model',
        'To incorporate the verticality of the local urban surface'
      ],
      answer: 0),
  Question(
      order: 77,
      text:
          '''
In the study - Kratzert F, Klotz D, Brenner C, Schulz K, Herrnegger M. Rainfall-runoff modelling using long short -term memory (LSTM) networks. Hydrology and Earth System Sciences. 2018 Nov 22;22(11):6005-22., LSTMs have been found to be performing better than traditional RNNs when one single network is used for trained individually for each basin, both for snow -influence catchments and arid catchments. Which one of the following is/are important contributor(s) for these results as stated by the authors?
I. The inability of a traditional RNN to learn long-term dependencies as compared to LSTMs
II. A traditional RNN is trained to minimize the average RMSE between observation and simulation )
III. Catchments contain processes with long-term dependencies such as snow accumulation and amount of precipitation.''',
      options: [
        'I',
        'II',
        'II and III',
        'I and III'
      ],
      answer: 3),
  Question(
      order: 78,
      text:
          'Which of the following is NOT a probable cause of bias arising in a numerical model for weather and climate modelling?',
      options: [
        'Data Assimilation',
        'Imperfect initial conditions',
        'Inaccurate physical parameterization',
        'Unresolved sub grid processes'
      ],
      answer: 0),
  Question(
      order: 79,
      text:
          'Match the items in the abbreviations in column-1 with the most relevant interpretation in column-2 in the context of Earth system science. Abbreviation Interpretation \nA1:  GRACE  I1:  Framework for comparing Earth System Models \nA2:  4D-Var I2:  Organization studying climate change \nA3:   CMIP I3:  Data Assimilation Algorithm \nA4:  IPCC I4:  Surface Mass and Total Water Storage through changes in Earth\'s gravity field',
      options: [
        '(A1, I4), (A2, I3), (A3, I2), (A4, I1)',
        '(A1, I4), (A2, I1), (A3, I3), (A4, I2)',
        '(A1, I4), (A2, I3), (A3, I1), (A4, I2)',
        '(A1, I3), (A2, I4), (A3, I1), (A4, I2)'
      ],
      answer: 2),
  Question(
      order: 80,
      text:
          'In the study -  Mansfield LA, Nowack PJ, Kasoar M, Everitt RG, Collins WJ, Voulgarakis A. Predicting global patterns of long -term climate change from short - ) term simulations using machine learning. npj Climate and Atmospheric Science. 2020 Nov 19;3(1):1-9., the authors advocate the need of a surrogate model for studying the mapping between short -term and long -term response patters against various forcings within a given GCM. What is the most important advantage of such a surrogate model?',
      options: [
        'Once designed it can replace computationally expensive numerical models for ever',
        'They are fast and more accurate than NWP models',
        'Once learned, this surrogate model can be used to rapidly predict long-term responses for unseen inputs (climate forcing scenarios).',
        'Surrogate models are always interpretable by design.'
      ],
      answer: 2),
];

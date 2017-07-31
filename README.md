# 2017 파이썬으로 배우는 추천시스템 Workshop

## 1. 실습 환경 구축

### 1.1 Python 실습 환경 설치
* [Python 설치](https://www.python.org/downloads/)
* [PIP 설치](https://pip.pypa.io/en/stable/installing/)
* [pandas 설치](http://pandas.pydata.org/)
    > `pip install pandas`
* [scipy 설치](https://www.scipy.org/install.html)
    > `pip install scipy`
* [scikit-learn 설치](http://scikit-learn.org/stable/install.html)
    > `pip install -U scikit-learn`

### 1.2 Jupyter Notebook 설치
* http://jupyter.org/install.html

### 1.3 실습 데이터 다운로드
* ~~Movielens [ml-latest-small.zip](http://files.grouplens.org/datasets/movielens/ml-latest-small.zip)~~
* Movielens [ml-latest-small-fastcampus.zip](https://s3.ap-northeast-2.amazonaws.com/ym-education/fastcampus/ml-latest-small-fastcampus.zip)

### 1.4 성능 평가 실습
Movielens 평점 데이터를 기반으로 MAE와 RMSE를 계산하는 실습을 수행합니다.
평점 데이터를 9:1로 학습, 검증 데이터로 나눕니다. 학습 데이터를 이용해서 아래의 세가지 방법을 이용해서 사용자의 영화에 대한 평점을 예측 합니다.

* 전체 영화의 평균 평점
* 각 사용자의 영화에 대한 평균 평점
* 각 영화의 평균 평점

세 가지 방법의 MAE와 RMSE를 계산하고 비교하여 봅니다.

## 2. Exploiting Explicit Feedback - 평점 예측을 이용한 영화 추천

### PostgreSQL 설치 및 설정
* https://www.postgresql.org/download/
* Create DB: fcrec
* Create User: fcuser//fcuser123

### 2.1 Math Background
* Vector and Matrix 표현
* 유사도 함수
    * TF-IDF
    * Cosine Similarity
    * Pearson Correlation
* [exercise-2.1.ipynb](movielens/exercise-2.1.ipynb)

### 2.2 User Profile based CBF 알고리즘을 이용한 영화 로직 구현
* 아이템 메타데이터를 이용해서 아이템간 유사도를 계산
* 사용자 프로파일을 사용자 평점을 부여한 아이템 목록으로 표현
* 아이템 목록에 있는 아이템과 유사한 다른 아이템들을 추천 아이템으로 생성
* [exercise-2.2.ipynb](movielens/exercise-2.2.ipynb)

### 2.3 Regression Model을 이용한 평점 예측 기반 영화 추천 로직 구현
* 회귀 모델 (regression model)을 이용하여 사용자 프로파일 생성
* 회귀 모델 프로파일을 이용하여 아이템 평점 예측
* [exercise-2.3.ipynb](movielens/exercise-2.3.ipynb)

### 2.4 Item-based CF 알고리즘을 이용한 영화 추천 로직 구현
* 평점 분포를 이용한 아이템간 유사도 계산
* 사용자 프로파일을 사용자 평점을 부여한 아이템 목록으로 표현
* 아이템 목록에 있는 아이템과 유사한 다른 아이템들을 추천 아이템으로 생성

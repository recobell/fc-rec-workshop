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
* [exercise-2.4.ipynb](movielens/exercise-2.4.ipynb)

### 2.5 User-based CF 알고리즘을 이용한 영화 추천 로직 구현
* 평점 분포를 이용한 사용자간 유사도 계산
* 나와 유사한 사용자가 각 아이템에 부여한 평점을 기반으로 평점 추정
* [exercise-2.5.ipynb](movielens/exercise-2.5.ipynb)



## 3. Exploiting Implicit Feedback - 트랜잭션 데이터 기반 e-commerce 상품 추천

### 데이터 다운로드 및 Postgresql 생성
* Download Commerce Data
    * [View Log]( http://pakdd2017.recobell.io/site_view_log_small.csv000.gz)
    * [Order Log]( http://pakdd2017.recobell.io/site_order_log_small.csv000.gz)
    * [Product Metadata]( http://pakdd2017.recobell.io/site_product_w_img.csv000.gz)
* [PostgreSQL 설치 및 DB 생성](https://www.postgresql.org/download/)
* 실습용 DB 생성
    * Create DB: fcrec
    * Create User: fcuser//fcuser123
    * [init-db.sql](init-db.sql)

### 3.0 데이터 로딩 및 확인 
* 테이블 생성 및 데이터 로딩: 
    * [01init.sql](commerce/01init.sql)
    * [02refine.sql](commerce/02refine.sql)
* psycopg2 설치
    > `pip install psycopg2`
* Jupyter에서의 DB 데이터 조회
    * [exercise-3.0.ipynb](commerce/exercise-3.0.ipynb)

### 3.1 Best Recommendation
* 조회 기반 베스트
* 구매 기반 베스트
* 사이트 전체 베스트
* 카테고리 별 베스트
* [03best.sql](commerce/03best.sql)

### 3.2 Related Recommendation
* 사용자 기준 연관 추천
* 세션 기준 연관 추천
* 인접 기준 연관 추천
* [04rel.sql](commerce/04rel.sql)

### 3.3 Personalized Recommendation
* 연관 추천을 이용한 개인화
* KNN 기반 개인화
* [05personalized.sql](commerce/05personalized.sql)

# 🎸 JDTuner

- 디바이스 마이크를 통한 소리의 주파수 탐지를 제공하는 iOS 튜너 애플리케이션  
- JUCE 및 C++로 직접 구현한 YIN 알고리즘 기반의 DSP 엔진을 코어로 사용  
- Objective-C++ 브릿지를 통해 SwiftUI와 분리된 구조  
- 개발 기록 : [블로그 링크](https://jd-man.tistory.com/category/JDTuner)

------------------------------------------------------------  

# 📹 실행 영상

<div align="center">
  <a href="https://www.youtube.com/watch?v=bxciA4DR3jc" target="_blank">
    <img src="https://img.youtube.com/vi/bxciA4DR3jc/maxresdefault.jpg" alt="JDTunerDemo" width="80%" />
  </a>
</div>  


------------------------------------------------------------  

# 🛠 Tech Stack
- iOS: 
- UI: Swift, SwiftUI, Combine
- Audio Input: JUCE
- Bridge: Objective-C
- DSP Core: C++

------------------------------------------------------------  

# ✨ Key Features
### High-Precision Pitch Detection
- YIN 알고리즘(차이 함수, 정규화, Parabolic Interpolation)을 적용   
- 배음이 섞인 기타/베이스 소리에서도 기본 주파수(Fundamental Frequency)를 추출
### Data-Driven Tuning Modes  
- C++ 엔진 코드의 수정 없이, 딕셔너리 기반의 프리셋 주파수 주입만으로 다양한 튜닝 모드 변환  
- Guitar Standard E, Guitar Drop D, Bass 4-String Standard    
### Reactive & Smooth UI  
- SwiftUI로 구현된 직관적이고 메탈릭한 디자인의 방사형 게이지 뷰  
- 오차 범위(Cents)에 따른 네온 글로우(Neon Glow) 이펙트 피드백  
- smoothLimit과 smoothRate를 활용한 바늘의 Jitter(떨림) 방지 및 부드러운 애니메이션  

------------------------------------------------------------

# 🏗 Architecture

<p align="center">
<img src="https://img1.daumcdn.net/thumb/R1280x0/?scode=mtistory2&fname=https%3A%2F%2Fblog.kakaocdn.net%2Fdna%2FbaywUz%2FdJMcab4MA9p%2FAAAAAAAAAAAAAAAAAAAAAFEDdWnC5N0Cx0i_mWdnLrwJzPB1qJ9Dd51hADqeuGf8%2Fimg.png%3Fcredential%3DyqXZFxpELC7KVnFOS48ylbz2pIh7yKj8%26expires%3D1777561199%26allow_ip%3D%26allow_referer%3D%26signature%3DSxBsqG7UsbvAv1AkU3R2%252F4YA8Ys%253D" width="70%">
</p>


### 1.	UI Layer (SwiftUI)
- 사용자 입력을 처리하고 튜닝 결과를 화면에 렌더링  
- C++ 엔진이나 복잡한 계산 로직을 전혀 알지 못하며, 오직 데이터의 표현에만 집중  

### 2.	Wrapper Layer (Objective-C)
-	Swift와 C++ 사이의 통역 역할
-	Swift의 NSString을 C++의 std::string으로, C++의 구조체를 Swift의 NSDictionary로 안전하게 변환하여 전달  

### 3.	Engine Layer (+ JUCE Framework, C++)
- JUCE iOS Static Library
- JUCE의 IO 기능을 활용하고 DSP 튜너 로직을 실행해 결과값을 얻어 Wrapper로 전달

### 4. Core DSP Layer (YIN Algorithmm C++)
- 독립적인 C++ 모듈
- 의존성이 없어 다른 OS(Android, Windows 등)나 오디오 플러그인(VST/AU) 개발 시 언제든 재사용이 가능


---------------------------------------------------

# 🚀 Getting Started
실행방법 : 없음 ㅎ   
환율 및 친구비 이슈로 출시 포기.
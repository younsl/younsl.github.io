---
marp: true
header: "SRE Weekly"
paginate: true
style: |
  section {
    color: white; /* 폰트 컬러를 흰색으로 설정 */
    background-color: black; /* 배경색을 블랙으로 설정 */
  }
  table {
    color: black;
  }
footer: "© 2025 Younsung Lee. All rights reserved."
---

## GSS

Slack Canvas로 운영 현황 자동화하기

---

### Topic

- GSS
- Slack canvas
- Scanning Output
- Golang 모범사례

---

### GSS

Scanner for scheduled workflows in GitHub Enterprise Server

![](./assets/1.png)

---

### GSS Language

Golang으로 작성된 컨테이너화된 프로그램이며 **헬름 차트** 지원.

![](./assets/2.png)

---

### Slack canvases API

![](./assets/3.png)

슬랙에서 제공하는 [Canvases API](https://api.slack.com/methods?query=canvases)로 캔버스 페이지를 CRUD 가능

---

### Scanning Output

GSS가 cronJob 스케줄에 맞춰 슬랙 캔버스에 Scheduled Workflow 기록

![bg right:60% 100%](./assets/4.png)

---

### Golang 모범사례

개발할 때 참고할 만한 모범사례

- [Go Standard Project](https://github.com/golang-standards/project-layout)

---

### EOD.

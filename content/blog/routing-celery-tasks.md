---
title: "Celery task의 queue 라우팅"
date: 2022-04-21T23:33:00+09:00
lastmod: 2022-04-22T21:44:33+09:00
slug: ""
description: "Celery 다루는 방법을 소개하는 글 (작성중)"
keywords: []
tags: ["python", "celery"]
---

## 개요

Celery worker의 Queue를 설정하는 방법을 소개합니다.

&nbsp;

## 환경

- **Celery** : 5.2.3 (dawn-chorus)
- **Python** : 3.8.13
- **Shell** : bash  

&nbsp;

## 본문

### 테스크 이름으로 큐 분류

**Task 파일 수정**  
`app.conf.task_queues` 설정을 통해 테스크 이름에 따라 큐를 분류할 수 있다.

```python
# celery_tasks.py
from celery import Celery
from kombu import Queue
import time

app = Celery('tasks', broker='redis://localhost:6379', backend='redis://localhost:6379')
app.conf.task_default_queue = 'default'
app.conf.task_queues = (
    Queue('normal_tasks', routing_key='normal.#'),
    Queue('urgent_tasks', routing_key='urgent.#'),
)


@app.task
def normal_task(x):
    time.sleep(x)
    return x


@app.task
def urgent_task(x):
    return x
```

&nbsp;

**Celery worker 띄우기**  
`celery_tasks.py` 파일을 작성했다. 이제 쉘에서 워커를 띄우면 된다.  
위 시나리오에서는 Queue가 총 2개(`slow_tasks`, `quick_tasks`)이기 때문에, Celery Worker도 각각 큐마다 띄워주어야 한다.

```bash
$ celery -A celery_tasks worker -Q normal_tasks -l INFO
$ celery -A celery_tasks worker -Q urgent_tasks -l INFO
```

**명령어 옵션 설명**  
`-A`: Celery Worker가 수행할 App 이름(파일명)을 지정하는 옵션  
`-Q`: Queue 이름을 지정하는 옵션  
`-l`(`--loglevel`): 출력할 로그레벨 옵션. Celery worker의 로그 레벨에는 DEBUG(디버그), INFO(정보성), WARNING(경고), ERROR(오류), CRITICAL(치명), FATAL(심각)이 있다.

&nbsp;

### 특정 테스크에만 큐 지정하기

`@app.task` 데코레이터에 `queue='QUEUE_NAME'` 파라미터를 지정하는 방법도 있다.

```python
@app.task(queue='normal_tasks')
def normal_task(x):
    time.sleep(x)
    return x
```

Celery worker 인스턴스를 동작시키는 방법은 위에 내용을 참고하면 된다.

&nbsp;

## 참고자료

[How to route tasks to different queues with Celery and Django](https://stackoverflow.com/questions/51631455/how-to-route-tasks-to-different-queues-with-celery-and-django)  
특정 테스크에만 큐 지정하는 방법을 소개하는 글.

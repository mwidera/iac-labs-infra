# Laboratorium numer 4

Pierwsze dwa zadania będą skoncentrowane na kubernetes
Kolejne zadanie jest przykładem analizy pod kontem bezpieczeństwa
Ostatnie zadanie wymaga platformy AWS, więc niezbędne będzie ustawienie kluczy dostępu do naszego konta w celu wdrożenia funkcji (elementu bezserwerowego)

## Przed laboratorium

Ćwiczenia 1-3 można wykonywać na platformach:

- [Killercoda](https://killercoda.com/kubernetes/scenario): Dostęp jest tylko do jednej maszyny wirtualnych i tylko na 60 minut
- [Play-With-Kubernetes](https://labs.play-with-k8s.com/): Można tworzyć więcej maszyn wirtualnych i na 3 godziny, lecz występują ograniczenia patrz komentarz niżej

Uwaga: Niestety przez to, iz Play With Kubernetes ma ograniczone zasoby czasami będzie należało stworzyć ponownie maszynę od zera z uwagi na nietypowe błędy w tworzeniu maszyn wirtualnych

## Zadanie 1: Tworzenie klastra Kubernetes

Kroki obowiązkowe tylko dla portalu: PWK (_Play With Kubernetes_)

- Wydaj polecenie: `kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.5.0.0/16`
- Poczekaj na zakończenie polecenia - może zając to parę minut
- Stwórz nową maszynę wirtualną (node2)
- (Node1): Skopiuj klucz wyglądający podobnie do zaprezentowanego `kubeadm join --token TOKEN ADDRESS --discovery-token-ca-cert-hash HASH`
- (Node2): Wklej go i uruchom
- (Node2): Obserwuj dołączanie do klastra
- (Node1): Wydaj polecenie `kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml`
- (Node1): Poczekaj na zakończenie się skryptu
- (Node1): Wydaj polecenie `kubectl get nodes`

Drugi etap zadania to uruchamianie Podów na klastrze
Do tego celu należy stworzyć wdrożenie (_deployment_)

- (Node1): Wykonaj następującą komendę: `kubectl apply -f https://k8s.io/examples/application/deployment.yaml`
- (Node1): Wyświetl informacje o tym w jakim stanie jest wdrożenie: `kubectl describe deployment nginx-deployment`
- (Node1): Sprawdź czy wdrożenie powiodło i Pody zostały uruchomione prawidłowo: `kubectl get pods -l app=nginx`
- (Node1): Skopiuj nazwę jednego z nich i wyświetl szczegóły z wykorzystaniem komendy `kubectl describe pod <nazwa>`
- (Node1): Aktualizacja wdrożenia (_deployment_): Wykonaj następujące polecenie: `kubectl apply -f https://k8s.io/examples/application/deployment-update.yaml`
- (Node1): Zaobserwuj jak poprzednie Pody są usuwane, a nowe wdrażane: `kubectl get pods -l app=nginx`
- (Node1): Edytuj wdrożenie poleceniem: `kubectl edit deployment/nginx-deployment` i zmień ilość replik z 2 na 4, a następnie zapisz plik
- (Node1): Zaobserwuj wdrożona zmianę `kubectl get pods`
- (Node1): Tymczasowo upublicznij serwer nginx poleceniem: `kubectl port-forward <pod> 80:80 --address=0.0.0.0`
- (Node1): Przetestuj działanie przechodząc do adresu na porcie 80
Notka: W przypadku Killercoda naciśnij w prawym górnym rogu znak: ≡ i wybierz `Traffic/Ports`
- (Node1): Usuń wdrożenie `kubectl delete deployment nginx-deployment`

- Ostatnim elementem jest uruchomienie przykładowej aplikacji z gotowego scenariusza:
[aplikacja](https://killercoda.com/linkerd/scenario/demo-app)
(Proszę przeklinać i otrzymamy gotową aplikacje do glosowania na emoji)

Pytania:

- Porównaj Kubernetes do Dockera

## Zadanie 2: Helm i helm chart

Kroki obowiązkowe tylko dla portalu: PWK (_Play With Kubernetes_)

- Pobierz na maszynę następujące archiwum:
  `curl -fsSL -o helm.tar.gz https://get.helm.sh/helm-v3.11.0-linux-amd64.tar.gz`
- Rozpakuj archiwum: `tar -zxvf helm.tar.gz`
- Przenieś aplikacje: `mv linux-amd64/helm /usr/local/bin/helm`
- Sprawdź działanie poleceniem: `helm version --short` i spodziewany efekt: `v3.11.0+g472c573`

Druga cześć zadania jest oparta o poprzednie wdrożenie serwera nginx

- Stwórz folder nowego wdrożenia poleceniem: `helm create nginx-chart`
- Przejdź do katalogu `nginx-chart` i usuń zawartość `templates` oraz folder `charts`
- Otwórz plik `Chart.yaml`
- Zmień zawartość pliku na:

```yaml
apiVersion: v2
name: nginx-chart
description: nginx backend
type: application 
version: 0.1.0
appVersion: "1.0.0"
```

Trochę opisu:
apiVersion - wersja aktualnie używanego API (v1 lub v2)
type - można również tworzyć biblioteki (library)
version - wersja tego pliku
appVersion - wersja naszej aplikacji

- Otwórz plik `values.yaml` i dodaj w nim:

```yaml
replicaCount: 4

image:
  repository: nginx
  tag: "1.20.0"
  pullPolicy: IfNotPresent

service:
  name: nginx-service
  type: ClusterIP
  port: 80
  targetPort: 9000

env:
  name: dev
```

- Dodaj plik `templates/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: "nginx:1.16.0"
          imagePullPolicy: IfNotPresent
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
```

- Ten plik na chwilę obecną nie jest jeszcze dynamicznie edytowalny, więc potrzebujemy zmodyfikować pola, które będą korzystać z elementów zadeklarowanych w pliku `Chart.yaml`
- Zamień nazwę (_name_) kontenera z `nginx` na `{{ .Chart.Name }}`
- Zamień ilość zreplikowanych Podów na wartość `{{ .Values.replicaCount }}`
- Zamień obraz kontenera na `image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"`
- Zamień politykę obierania obrazu na `imagePullPolicy: {{ .Values.image.pullPolicy }}`
- Do katalogu `templates` dodaj kolejny plik `configmap.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-index-html-configmap
  namespace: default
data:
  index.html: |
    <html>
    <h1>Welcome</h1>
    </br>
    <h1>Hello World from {{ .Values.env.name }} Environment using Helm</h1>
    </html
```

- Oraz tak samo jak wyżej plik `service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Release.Name }}-service
spec:
  selector:
    app.kubernetes.io/instance: {{ .Release.Name }}
  type: {{ .Values.service.type }}
  ports:
    - protocol: {{ .Values.service.protocol | default "TCP" }}
      port: {{ .Values.service.port }}
      targetPort: {{ .Values.service.targetPort }}
```

Zauważ, ze protokół ma wartość domyślna ustawiona przez znak `|`

- Teraz z lini komend jeśli jesteś w katalogu `nginx-chart` wydaj polecenie `helm lint .`
- Teraz wygeneruj plan wdrożenia `helm template .` czyli docelowy wygląd wdrożenia
- Przejdź do katalogu głównego poleceniem `cd ~`
- Jeśli wszystko poszło pomyślnie i nie ma błędów (_Error_) możemy wydać polecenie instalowania: `helm install nginx nginx-chart`
- Zweryfikuj pomyślne wdrożenie poleceniami:
  - `helm list` (zwróć uwagę, iz narzędzie inkrementuje wersje przez klucz `REVISION`)
  - `kubectl get deployment`
  - `kubectl get configmap`
  - `kubectl get services`
  - `kubectl get pods`

Jeśli wszystko działa prawidłowo możesz zaktualizować dane wdrożenie przy użyciu pliku (stwórz go np. w katalogu głównym `envs/prod.yaml`)

```yaml
replicaCount: 10

image:
  repository: nginx
  tag: "1.20.0"
  pullPolicy: IfNotPresent

service:
  name: nginx-service
  type: ClusterIP
  port: 80
  targetPort: 9000

env:
  name: prod
```

- Przejdź do katalogu głównego poleceniem `cd ~`
- Wdrożenie tym razem wykonaj przy użyciu aktualizacji (nie instalacji): `helm upgrade nginx nginx-chart --values envs/prod.yaml`
- Sprawdź czy aplikacja została wyskalowana do 10 replik
- Przeciwnie do `upgrade` Helm wspiera również `rollback`, wykonaj polecenie i odnotuj rezultat
- Usuń wdrożenie (_deployment_) `helm uninstall nginx`

Pytania:

- Czym jest Helm dla Kubernetes?

## Zadanie 3: Analiza bezpieczeństwa

Ostatnim zadaniem będzie zapoznanie się z narzędziami pozwalającymi na wykrywanie potencjalnych problemów w naszym kodzie

Pierwszym narzędziem jest [Terrascan](https://github.com/tenable/terrascan)

- Pobierz narzędzie poleceniem `curl -L -o terrascan.tar.gz https://github.com/tenable/terrascan/releases/download/v1.17.1/terrascan_1.17.1_Linux_x86_64.tar.gz`
- Wypakuj archiwum: `tar -xf terrascan.tar.gz terrascan`
- Zainstaluj: `install terrascan /usr/local/bin && rm terrascan`
- Zweryfikuj czy narzędzie działa: `terrascan`
- Wydaj polecenie `terrascan scan --help` (zwróć uwagę na typy możliwej analizy `--iac-type` oraz katalog do skanowania: `--iac-dir`)
- Jeśli musiałeś do zadania od nowa stworzyć środowisko to pobierz repozytorium laboratorium
- Przejdź do katalogu `iac-labs-infra/terraform` i wykonaj skanowanie dla kodu typu `terraform`
- By przeskanować obraz dockera przejdź do katalogu `iac-labs/example-app`
  (jeśli go nie ma to `cd && cd iac-labs-infra && git submodule init && git submodule update`)
- Wykonaj analizę poleceniem: `terrascan scan -i docker`
- Na koniec mamy jeszcze przykład ostatniego typu `ctf` przejdź do katalogu `iac-labs/infra/lab2/zad4` z laboratorium 2
- Wykonaj skanowanie `terrascan scan -i cft`
- Na koniec ostatnie ciekawe zastosowanie: `terrascan scan -i k8s -r git -u https://github.com/kubernetes/examples.git`
  (Uwaga: Możliwe, ze zawiesi nam sie konsola tymczasowo)

Pytania:

- Co analizuje Terrascan?
- Czy to narzędzie gwarantuje bezpieczeństwo wdrożeń?
- Poszukaj alternatywnych programów i zaproponuj

## Zadanie 4: Bezserwerowe Hello World

Zadanie wymaga konsoli AWS (CloudShell) i ma na celu przybliżyć działanie aplikacji bezserwerowych

- Wykonaj polecenie `curl -o- -L https://slss.io/install | bash`
- Edytuj ścieżkę systemową: `export PATH="$HOME/.serverless/bin:$PATH"`
- Wykonaj polecenie: `serverless` i wybierz `AWS - Python - Starter`
- Nie rejestruj się do _Serverless Dashboardu_ (naciśnij `n` i enter)
- Wykonaj wdrożenie aplikacji (potwierdź, ze chcesz wykonać _deployment_)
Notka: Aplikacja poprosi nas o klucze AWS nawet pomimo iz pracuje na naszym koncie, więc musimy podać wartość AWS_ACCESS_KEY_ID i AWS_SECRET_ACCESS_KEY
- Przejdź do katalogu (domyślnie `aws-python-project`)
- Wydaj polecenie `serverless invoke --function hello`

Oczekiwany rezultat:

```json
{
    "statusCode": 200,
    "body": "{\"message\": \"Go Serverless v3.0! Your function executed successfully!\", \"input\": {}}"
}
```

- Na drugiej zakładce otwórz stworzoną funkcje w AWS Lambda
- Wejdź to `aws-python-project-dev-hello` i przejdź do zakładki `Configuration`
- Stwórz adres zewnętrzny dla funkcji (_Create function url_)
- Wybierz opcje bez uwierzytelniania (_NONE_) i naciśnij Save
- Pojawi się adres (_Function URL_)
- Przejdź do niego i sprawdź co zwraca
- Gratulacje twoja bezserwerowa powinna działać poprawnie!
- Usuń adres URL
- Ponownie przejdź do zakładki z konsolą i wydaj polecenie `serverless remove`

Pytania:

- Podaj przykładowe zastosowania dla bezserwerowych funkcji
- Co jest główną zaletą dla programistów w tym podejściu?

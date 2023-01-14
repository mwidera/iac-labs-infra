# Laboratorium numer 3

Terraform:

- Składnia
- Modularyzacja
- Idempotentność

Tworzenie stosów na platformie AWS

Pulumi:

- Składnia
- Modularyzacja
- Idempotentność

Tworzenie stosów na platformie AWS

## Przed laboratorium

Dokumentacja narzędzi użytych do realizacji zadania:

-[Terraform](https://developer.hashicorp.com/terraform/docs)
-[Pulumi](https://www.pulumi.com/docs/get-started/)

-[Dokumentacja zasobów terraform](https://registry.terraform.io/browse/providers)
-[Dokumentacja zasobów pulumi](https://www.pulumi.com/registry/)

Instalacja zależności:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Pulumi](https://www.pulumi.com/docs/get-started/aws/begin/)

Adres repozytorium:
[https://github.com/mwidera/iac-labs-infra](https://github.com/mwidera/iac-labs-infra)

Instalacja narzędzi na platformie Play-With-Docker:

1. Terraform:
  
- Wykonaj polecenie: `wget https://releases.hashicorp.com/terraform/1.3.7/terraform_1.3.7_linux_amd64.zip`
- Wykonaj polecenie: `unzip terraform_1.3.7_linux_amd64.zip`
- Przesuń plik: `mv terraform /usr/local/bin`
- Sprawdź działanie aplikacji: `terraform --version`

1. Pulumi

- Wykonaj polecenie: `curl -fsSL https://get.pulumi.com | sh`
- Ustaw zmienną PATH: `export PATH=$PATH:/root/.pulumi/bin`
- Zweryfikuj działanie `pulumi version`

## Zadanie 1: Terraform składnia, idempotentność, modularność

- Ustaw następujące zmienne systemowe (klucz i sekret pobierz z konta AWSowego)

  *Dla osób bez dostępu do AWSa:* Ustaw takie jak widzisz, lecz nie wydawaj polecenia `terraform apply`!

  ```bash
  export AWS_ACCESS_KEY_ID=ALAMAKOTAASDASDX
  export AWS_SECRET_ACCESS_KEY="przykladowykluczo2KyARbABVJavS2b1234"
  ```

- Wykonaj klonowanie repozytorium do przestrzeni roboczej
- Wydaj polecenie pobrania git modułu (potrzebne do zadań 3 i 6):

  ```bash
  git submodule init
  git submodule update
  ```

- Przejdź do katalogu terraform/zad1
- Kolejne zadania 1-import, 2-zmienne, 3-moduły, 4-funkcje pozwolą poznać składnie
- Przejdź do każdego z wymienionych wyżej katalogów otwierając plik `main.tf` jako funkcje główną programu
- Wykonaj polecenie inicjujące narzędzie: `terraform init`
- Zaobserwuj jakie zależności zostały pobrane
- Wykonaj polecenie tworzące plan aplikowania infrastruktury: `terraform plan`
- Zaaplikuj plan poleceniem `terraform apply`
- Zweryfikuj działanie stworzonej infrastruktury
- Wydaj raz jeszcze polecenie `terraform plan/apply` by sprawdzić, czy stos jest idempotentny
- Zniszcz środowisko poleceniem `terraform destroy`

Notka:

- Dla zadania 3-module w linii 47 pliku `main.tf` zmodyfikuj AMI przed zaaplikowaniem w innej chmurze!

Pytania:

- Wyjaśnij zasadę działania sekcji `variables` oraz `outputs`
- Jakie ma zastosowanie blok kodu umieszczony poniżej?

  ```terraform
  provider "aws" {
    region = "eu-central-1"
  }

  provider "aws" {
    alias  = "east"
    region = "us-east-1"
  }
  ```

## Zadanie 2: Terraform lokalnie

Zadanie jest zbliżone do poprzedniego z tym wyjątkiem, iz do jego realizacji nie jest niezbędny AWS

- Wykonaj polecenie inicjujące narzędzie: `terraform init`
- Zaobserwuj jakie zależności zostały pobrane
- Wykonaj polecenie tworzące plan aplikowania infrastruktury: `terraform plan`
- Zaaplikuj plan poleceniem `terraform apply`
- Zweryfikuj działanie stworzonej infrastruktury
- Zmodyfikuj infrastrukturę zmieniając oznaczenie obrazu wykorzystując zasób [docker_tag](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/tag)
  Przykładowy zasób jaki należy dodać do :

  ```terraform
  resource "docker_tag" "tag_<indeks>" {
    <<wykorzystaj_dokumentacje>>
  }
  ```

- Zaaplikuj zmiany poleceniami `terraform plan` i `terraform apply`
- Zniszcz środowisko poleceniem `terraform destroy`

Pytania:

- Wyjaśnij jest plik `terraform.tfstate`
- Wyjaśnij w jaki sposób współdzielenie `terraform.tfstate` zagwarantuje idempotentne podejście tworzenia infrastruktury

## Zadanie 3: Uruchomienie example-app

Uruchomienie aplikacji lokalnie jako element odwzorowania środowiska docelowego

- Przejdź do katalogu terraform/zad3
- Zapoznaj się ze składnią stworzonego stosu
- Dodaj brakujący zasób (bazę danych) z wykorzystaniem sekcji `resource`
  Składnia kontenera dostępna jest pod tym [adresem](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container)
  Kontener nazwij `db`
  Obraz na którym bazujesz to `resource "docker_image" "postgres"` opisany w pliku `images.tf`
  Podepnij kontener do wspólnej wirtualnej sieci `tfnet`
  Dodaj zmienne środowiskowe niezbędne do poprawnego działania stworzonego kontenera:

  ```bash
    "POSTGRES_DB=app",
    "POSTGRES_USER=app_user",
    "POSTGRES_PASSWORD=app_pass"
  ```

Pytania:

- Porównaj podejście do tworzenia lokalnego środowiska z wykorzystaniem docker-compose oraz terraform
- Podaj zalety tak realizowanego lokalnego środowiska

## Zadanie 4 - Terraform i AWS

Tworzenie stosu przykładowej aplikacji na chmurze AWS
Do tego celu jak w poprzednim laboratorium wykorzystamy AppRunner, ECR oraz obraz który będzie dostarczony do repozytorium

- Przejdź do katalogu `terraform/zad4/apprunner`
- Zainicjuj narzędzie terraform wykorzystując polecenie `terraform init`
- Zaobserwuj jakie zależności zostały pobrane
- Wykonaj polecenie tworzące plan aplikowania infrastruktury: `terraform plan`
- Zaobserwuj ile zasobów planuje stworzyć narzędzie
- Zaaplikuj plan poleceniem `terraform apply`
- Zweryfikuj działanie stworzonej infrastruktury klikając w adres podany w wyniku
  
Część druga: dodawanie ECR:

- Przejdź do katalogu `../ecr`
- Wybuduj obraz aplikacji z wykorzystaniem obrazu dockera
- Stwórz repozytorium obrazów z wykorzystaniem polecenia `terraform apply -target aws_ecr_repository.demo-repository`
- Wypchnij obraz do repozytorium obrazów

Notka dla osób z PlayWithDocker (ECR View Push Commands):

  1. Skopiuj pierwszą częśc do znaku `|` i wykonaj w Cloud Console
  2. Ustaw zmienną np foo=<CTRL+SHIFT+V>
  3. Wydaj resztę polecenia które znajdziesz w ECR zmieniając `--password-stdin` na `--password $foo`

- Zmodyfikuj AppRunner w taki sposób by wykorzystywał on ten obraz dockera do uruchomienia aplikacji
W tym celu wykorzystaj [dokumentacje](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apprunner_service)
- Zaaplikuj zmiany poleceniem `terraform apply`
- Po uruchomieniu i zweryfikowaniu działania aplikacji zniszcz środowisko `terraform destroy`
  Czy usunięte zostały wszystkie elementy?

## Zadanie 5 - Pulumi

- Przejdź do katalogu pulumi/zad1
- Wykonaj polecenie `pulumi new aws-python --force`
- Podaj parametry wykonania np. `project name: zad1`, `project description: Empty`, `stack name: nr_indeksu`
- Zapoznaj się z zawartością stworzonego projektu w pliku `__main__.py`
- Wydaj polecenie `pulumi up`
- Na potrzeby tego zadania każdy z uczestników musi dodać swoje środowisko do zdalnego zasobu zarządzania stanem (app.pulumi.com)
- Stwórz konto na potrzeby realizacji tego zadania (jest darmowe oraz można je stworzyć z wykorzystaniem GitHuba)
- Dodaj plik `index.html` w obecnym katalogu:

  ```html
  <html>
    <body>
        <h1>Hello, World!</h1>
    </body>
  </html>
  ```

- Zmodyfikuj plik `__main__.py` dodając:
  
  ```python
  bucketObject = s3.BucketObject(
    'index.html',
    acl='public-read',
    content_type='text/html',
    bucket=bucket.id,
    source=pulumi.FileAsset('index.html'),
  )
  ```

  zmień s3 bucket w następujący sposób:
  
  ```python
  bucket = s3.Bucket('my-bucket',
    website=s3.BucketWebsiteArgs(index_document="index.html")
    )
  ```
  
  ostatecznie zmień efekt końcowy tak by poznać adres statycznie stworzonej strony:

  ```python
  pulumi.export('bucket_endpoint', pulumi.Output.concat('http://', bucket.website_endpoint))
  ```

- Wydaj polecenie `pulumi preview` by zweryfikować wprowadzone zmiany
- Wykonaj polecenie `pulumi up` by wdrożyć zmiany
- Czy strona wynikowa działa?
- Zniszcz środowisko `pulumi down`

Pytania:

- Jakie języki programowania są wspierane przez Pulumi?
- Gdzie jest trzymany stan tworzonego stosu?

## Zadanie 6 - tworzenie lokalnego stosu

- Przejdź do katalogu pulumi/zad2
- Na potrzeby tego zadania zarówno jak i `__main__.py` zostały wstępnie przygotowane
- Zapoznaj się z plikiem i zaaplikuj go (tym razem nie ma obowiązku wydawania polecenia `pulumi new`)

Pytania:

- Porównaj tworzenie stosu z wykorzystaniem Pulumi do tworzenia stosu Terraform

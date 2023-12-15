# Laboratorium numer 2

## Terraform i Pulumi

- **Składnia**
- **Modularyzacja**
- **Idempotentność**
- Tworzenie stosów na platformie AWS

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

Instalacja narzędzi na platformie VDI:

- Sprawdź działanie aplikacji: `terraform --version`
- Wykonaj polecenie: `curl -fsSL https://get.pulumi.com | sh`
- Ustaw zmienną PATH: `export PATH=$PATH:/root/.pulumi/bin`
- Zweryfikuj działanie `pulumi version`

## Zadanie 1: Terraform - Składnia, Idempotentność, Modularność

### Dla osób nie korzystających z AWS

1. Wydaj następujące polecenia:

   ```bash
   python3 -m venv venv
   source venv/bin/activate`
   pip install terraform-local pulumi-local`
   ```

2. Ustaw aliasy: `alias terraform=tflocal` i `alias pulumi=pulumilocal`

### Ustawienie zmiennych systemowych

Klucz i sekret pobierz z konta AWSowego

- `export AWS_ACCESS_KEY_ID=ALAMAKOTAASDASDX`
- `export AWS_SECRET_ACCESS_KEY="przykladowykluczo2KyARbABVJavS2b1234"`

### Przygotowanie środowiska

- Wykonaj klonowanie repozytorium do przestrzeni roboczej
- Wydaj polecenie pobrania git modułu (potrzebne do zadań 3 i 6):

  ```bash
  git submodule init
  git submodule update
  ```

### Praca z Terraform

- Przejdź do katalogu terraform/zad1
- Otwórz plik `main.tf` w każdym z katalogów: 1-import, 2-zmienne, 3-moduly
- Wykonaj `terraform init` i obserwuj pobrane zależności.
- Użyj `terraform plan` i `terraform apply` do zaaplikowania infrastruktury.
- Zweryfikuj działanie infrastruktury
- Sprawdź idempotentność stosu poprzez ponowne wydanie polecenia `terraform apply`
- Wydaj polecenie `terraform state list` a następnie `terraform state show <nazwa_zasobu>` by poznać stan zasobów
- Zanotuj efekty powyzszych poleceń w sprawozdaniu - jako tekst (**nie** zrzut ekranu, albo załącznik)
- Zniszcz środowisko poleceniem `terraform destroy`

### Dodatkowa informacja do zadania 1/3-module

- W linii 47 pliku `main.tf` zmodyfikuj AMI przed zaaplikowaniem w chmurze AWS
- Wydaj polecenie `terraform taint <nazwa_zasobu>`, by oznaczyć zasób jako element do zastąpienia i ponów krok wcześniejszy

### Pytania

- Wyjaśnij działanie sekcji `variables` i `outputs`.
- Opisz zastosowanie `terraform taint`.
- Wyjaśnij działanie części kodu zamieszczonego poniżej:

  ```terraform
  provider "aws" {
    region = "eu-central-1"
  }

  provider "aws" {
    alias  = "east"
    region = "us-east-1"
  }
  ```

## Zadanie 2: Terraform z Docker'em

### Inicjowanie i Tworzenie Infrastruktury

- Wykonaj `terraform init`.
- Użyj `terraform plan` i `terraform apply`
  
### Modyfikacja Infrastruktury

- Zmodyfikuj infrastrukturę, korzystając z zasobu [docker_tag](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/tag).

  Przykładowy zasób jaki należy dodać do :

  ```terraform
  resource "docker_tag" "tag_<indeks>" {
    <<wykorzystaj_dokumentacje>>
  }
  ```

- Wydaj polecenie `terraform state list` a następnie `terraform show` by poznać stan zasobów
- Zanotuj efekty powyzszych poleceń w sprawozdaniu - jako tekst (**nie** zrzut ekranu, albo załącznik)
- Zniszcz środowisko poleceniem `terraform destroy`

### Pytania do zadania 2

- Wyjaśnij rolę pliku `terraform.tfstate`

## Zadanie 3: Uruchomienie example-app

Uruchomienie aplikacji lokalnie jako element odwzorowania środowiska docelowego

### Konfiguracja i Uruchomienie

- Przejdź do katalogu terraform/zad3
- Dodaj brakujący obraz w pliku `images.tf` z wykorzystaniem sekcji `resource`
  Składnia obrazu dostępna jest pod tym [adresem](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image)
  
  Obraz nazwij `postgres`

- Dodaj brakujący zasób (bazę danych) z wykorzystaniem sekcji `resource`
  Składnia kontenera dostępna jest pod tym [adresem](https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/container)
  
  Kontener nazwij `db`
  
  Podepnij kontener do wspólnej wirtualnej sieci `tfnet`

  Stworzony wcześniej obraz `postgres` wykorzystaj jako obraz bazowy dla kontenera `db`
  
  Dodaj zmienne środowiskowe niezbędne do poprawnego działania stworzonego kontenera:

  ```bash
    "POSTGRES_DB=app",
    "POSTGRES_USER=app_user",
    "POSTGRES_PASSWORD=app_pass"
  ```

- Wydaj polecenie `terraform state list` a następnie `terraform show` by poznać stan zasobów
- Zanotuj efekty powyzszych poleceń w sprawozdaniu - jako tekst (**nie** zrzut ekranu, albo załącznik)
- Zniszcz środowisko poleceniem `terraform destroy`

### Pytania do zadania 3

- Porównaj docker-compose i terraform w kontekście tworzenia lokalnego środowiska
- Jak wyglądałby plik docker-compose dla tego środowiska?

## Zadanie 4 - Pulumi

### Konfiguracja Pulumi

- Przejdź do katalogu pulumi/zad1
- Wykonaj polecenie `pulumi new aws-python --force`
- Podaj parametry wykonania np.
  
  ```text
  project name: zad1`, 
  project description: Empty`, 
  stack name: nr_indeksu
  ```

### Modyfikacja i Wdrożenie

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
  public_access_block = s3.BucketPublicAccessBlock(
    'public-access-block', 
    bucket=bucket.id, 
    block_public_acls=False
  )
  def public_read_policy_for_bucket(bucket_name):
    return pulumi.Output.json_dumps({
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                pulumi.Output.format("arn:aws:s3:::{0}/*", bucket_name),
            ]
        }]
    })
  s3.BucketPolicy('bucket-policy',
    bucket=bucket.id,
    policy=public_read_policy_for_bucket(bucket.id), 
    opts=pulumi.ResourceOptions(depends_on=[public_access_block])
  )

  bucketObject = s3.BucketObject(
    'index.html',
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

## Zadanie 5 - tworzenie lokalnego stosu

- Przejdź do katalogu pulumi/zad2
- Na potrzeby tego zadania zarówno jak i `__main__.py` zostały wstępnie przygotowane
- Zapoznaj się z plikiem i zaaplikuj go (tym razem nie ma obowiązku wydawania polecenia `pulumi new`)

Pytania:

- Porównaj tworzenie stosu z wykorzystaniem Pulumi do tworzenia stosu Terraform

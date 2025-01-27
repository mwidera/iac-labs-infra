# Laboratorium numer 4

Pierwsze dwa zadania dotyczą zarządzania konfiguracją z narzędziem [Ansible](https://docs.ansible.com/ansible/latest/index.html)

Trzy kolejne odnoszą się do pojęć Monitoringu i Alertingu z wykorzystaniem narzędzi: Grafana, Loki, Prometheus uruchomionych na klastrze Kubernetes

## Konfiguracja maszyny wirtualnej

Wykonaj poniższe kroki, aby skonfigurować maszynę wirtualną:

1. Sklonuj repozytorium:

   ```bash
   git clone https://github.com/mwidera/iac-labs-infra/tree/lab-4
   ```

2. Skonfiguruj uprawnienia Dockera:

   ```bash
   sudo groupadd docker; sudo usermod -aG docker $USER; newgrp docker
   ```

3. Zainstaluj Docker Compose (jeśli nie jest jeszcze zainstalowany):

   ```bash
   sudo apt install docker-compose
   ```

4. Zainstaluj `sshpass`:

   ```bash
   sudo apt install sshpass
   ```

---

## Zadanie 1: Konfiguracja Ansible

Wykonaj poniższe kroki, aby zastosować konfigurację Ansible:

1. Przejdź do katalogu `ansible/zad1`:

   ```bash
   cd ansible/zad1
   ```

2. Uruchom wymagane kontenery:

   ```bash
   docker compose up
   ```

3. Otwórz nowe okno terminala.

4. Przejdź do katalogu `ansible/zad1` w nowym terminalu:

   ```bash
   cd ansible/zad1
   ```

5. Utwórz wirtualne środowisko Python:

   ```bash
   python -m venv venv
   source venv/bin/activate
   ```

6. Zainstaluj Ansible:

   ```bash
   pip install ansible
   ```

7. Sprawdź, czy połączenie z uruchomionymi maszynami działa:

   ```bash
   ansible-playbook -i inventory.yaml test-connection.yaml
   ```

8. Zastosuj konfigurację `site.yaml`:

   ```bash
   ansible-playbook -i inventory.yaml site.yaml
   ```

9. Zatrzymaj kontenery:

   ```bash
   docker-compose down
   ```

## Zadanie 2: Uruchomienie Example App z wykorzystaniem Ansible

Wykonaj poniższe kroki, aby zastosować konfigurację Ansible:

1. Przejdź do katalogu `ansible/zad2`:

   ```bash
   cd ansible/zad2
   ```

2. Uruchom wymagane kontenery:

   ```bash
   docker compose up
   ```

3. Otwórz nowe okno terminala.

4. Przejdź do katalogu `ansible/zad2` w nowym terminalu:

   ```bash
   cd ansible/zad2
   ```

5. Utwórz wirtualne środowisko Python:

   ```bash
   python -m venv venv
   source venv/bin/activate
   ```

6. Zainstaluj Ansible:

   ```bash
   pip install ansible
   ```

7. Otwórz plik `playbook.yaml` i dodaj w nim:
   a. Instalację poetry z wykorzystaniem poniższej komendy:

   ```bash
      curl -sSL https://install.python-poetry.org | POETRY_HOME=/usr/local python3 -
   ```

   W tym celu wykorzystaj moduł [ansible.builtin.shell](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/shell_module.html)

   b. Dodaj również instalację zależności projektowych dla aplikacji z wykorzystaniem polecenia:

   ```bash
      cd /app && poetry install --no-root
   ```

8. Zastosuj konfigurację `playbook.yaml`:

   ```bash
   ansible-playbook -i inventory.yaml playbook.yaml
   ```

9. Jeśli poprzednia komenda została wykonana z wynikiem `ok` to pod adresem `http://localhost:8080` będzie dostępna aplikacja

## Zadanie 3: Monitoring z wykorzystaniem Grafana, Loki

1. Otwórz platformę KillerKoda i na scenariuszu [Kubernetes 1.31](https://killercoda.com/playgrounds/scenario/kubernetes)
2. Sklonuj repozytorium [tutorial-environment](https://github.com/grafana/tutorial-environment)

   ```bash
   git clone https://github.com/grafana/tutorial-environment.git
   ```

3. Przejdź do sklonowanego katalogu:

   ```bash
   cd tutorial-environment
   ```

4. Uruchom aplikację:

   ```bash
   docker-compose up -d
   ```

5. Upewnij się, że wszystkie serwisy zostały uruchomione poprawnie:

   ```bash
   docker-compose ps
   ```

   W kolumnie `State` wszystkie powinny mieć status `Up`

6. Otwórz adres: [http://localhost:8081](http://localhost:8081):
   a. Naciśnij burger menu w prawym górnym rogu (znak: ≡) i wybierz Traffic/Ports podając port: `8081`
7. Stwórz przykładowy wpis:
   a. Title: `Some title`
   b. URL: `http://example.com`
   c. Kliknij `Submit`
   d. Możesz również zagłosować na stworzony link klikając trójkątny przycisk

8. Przejdź pod adres: [http://localhost:3000](http://localhost:3000):
   a. Naciśnij w prawym górnym rogu znak: ≡ i wybierz Traffic/Ports podając port: `3000`
   b. Jeśli natrafisz na panel logowania: użytkownik `admin` hasło: `admin`
9. Naciśnij burger menu w lewym górnym rogu pod logo Grafany (znak: ≡)
10. Przejdź do `Explore`
   a. Na początku przeanalizujemy co jest publikowane do Grafany przez Prometheus
   a. Wybierz z menu `Metric` parę przykładowych metryk, by przetestować poprawność raportowania
   a. Na końcu wybierz: `tns_request_duration_seconds_count` - metryka ta jest typu `counter` zatem zachowuje się jak licznik - zlicza ilość odwołań w zależności od adresu oraz zwracanego kodu
   a. Wszystkie możliwe PromQL zapytania i szczegółowe instrukcje możesz znaleźć [tutaj](https:/arometheus.io/docs/prometheus/latest/querying/basics/)
   a. Zmodyfikuj Query, tak aby `tns_request_duration_seconds_count` było zliczane co 5 minut:
      - w tym celu zastosuj `rate(<nazwa>[5m])` - zastosowana funkcja `rate(...[5m])` sprawia, że licznik jest resetowany co 5 minut: [dokumentacja](https://prometheus.io/docs/prometheus/latest/querying/functions/#rate)
   a. Ostateczny wygląd funkcji:

   ```text
   rate(tns_request_duration_seconds_count[5m])
   ```

   a. Dodatkowo dodaj sumowanie na dany pod-adres API :

   ```text
   sum(rate(tns_request_duration_seconds_count[5m])) by(route)
   ```

11. Wróć teraz na zakładkę aplikacji (lecz zachowaj zakładkę z obecnym widokiem query):
  a. Naciśnij burger menu w prawym górnym rogu (znak: ≡) i wybierz Traffic/Ports podając port: `8081`
12. Wygeneruj trochę ruchu sieciowego na stronie: (Stwórz dodatkowe linki, głosuj na link, itd)
13. Po chwili wróć do zakładki Grafany i zaobserwuj zmiany na wykresie - ruch generowany powinien się zwizualizować na wykresie
14. Na koniec: Rozszerz dokładność grafu - w tym celu naciśnij ikonkę zegara nad wykresem po jego prawej stronie i wybierz: `Last 5 minutes` oraz `Last 15 minutes` by poznać możliwość zwiększania dokładności rysowanych wykresów

## Zadanie 4: Grafana dashboard oraz Loki

Jeśli masz ograniczony czas na platformie KillerKoda wykonaj punkty z zadania3: 1-4

1. Naciśnij burger menu w lewym górnym rogu pod logo Grafany (znak: ≡)
2. Przejdź do zakładki `Connections` i naciśnij `Data Sources`
3. Naciśnij `Add new data source`
4. Wyszukaj i wybierz z listy `Loki`
5. W zakładce URL wpisz: `http://loki:3100`
6. Na dole strony znajdziesz przycisk `Save & Exit`
7. Naciśnij burger menu w lewym górnym rogu pod logo Grafany (znak: ≡)
8. Przejdź do `Explore`
9. Zamień z pola wybieralnego Prometheus na Loki (lewy górny róg strony)
10. Wybierz logi z pliku `tns-app.log`:

   ```text
   {filename="/var/log/tns-app.log"}
   ```

Są to wszystkie logi z aplikacji - aplikacja loguje informacje w formacie logów w funkcji czasu
11. Na wykresie słupkowym można zaobserwować jak w jednostce czasu nasza aplikacja generowała logi
12. Teraz sprawdźmy ile z tych logów zawiera błędy w tym celu dodaj do zapytania: `|= "error"`
Wygląd całej komendy:

   ```text
   {filename="/var/log/tns-app.log"} |= "error"
   ```

13. Tworzenie dashboardu zaczniemy od przejścia do menu
14. Naciśnij burger menu w lewym górnym rogu pod logo Grafany (znak: ≡)
15. Przejdź do zakładki `Dashboards` i naciśnij `Create dashboard`
16. Naciśnij `Add visualization`
17. Jako źródło wybierz `Prometheus`
18. Ustaw zapytanie PromQL (Pod wykresem zakładka `Queries`)

   ```text
   sum(rate(tns_request_duration_seconds_count[5m])) by(route)
   ```

19. Nazwij wykres: `Ruch sieciowy` - Title po prawej stronie wykresu
20. W prawym górnym rogu znajdziesz "Save dashboard" i jeszcze raz nazwij go
21. Teraz dodatkowo dokonamy adnotacji na wypadek błędów - tutaj źródłem tych danych będzie Loki
22. Naciśnij burger menu w lewym górnym rogu pod logo Grafany (znak: ≡)
23. Przejdź do zakładki `Dashboards` i naciśnij `Create dashboard`
24. Naciśnij `Settings` i przejdź do zakładki `Annotations`
25. Naciśnij `Add annotation query`
26. Nazwij: `Errors`
27. Wybierz źródło danych: `Loki`
28. W Query wpisz: `{filename="/var/log/tns-app.log"} |= "error"`
29. Zapisz z wykorzystaniem `Save dashboard` w prawym górnym rogu
30. Przetestuj działanie: przejdź na zakładkę example app:
    2.  Naciśnij burger menu w prawym górnym rogu (znak: ≡) i wybierz Traffic/Ports podając port: `8081`
    3.  Wygeneruj losowy błąd
31. Błąd powinien zostać oznaczony pionową przerywaną czerwoną kreską na wykresie

## Zadanie 5: Alerting z wykorzystaniem Grafana Alerts oraz webhooks

Jeśli masz ograniczony czas na platformie KillerKoda wykonaj punkty z zadania3: 1-4
Dodatkowo z zadania4 należy powtórzyć punkty: 13-20

1. By przetestować serwis odbierający alerty wykorzystamy serwis odbierający webhooki: [webhook.site](https://webhook.site/)

2. Skopiuj unikalny adres przydzielony na pasku adresu
3. Naciśnij burger menu w lewym górnym rogu pod logo Grafany (znak: ≡)
4. Przejdź do zakładki `Alerting` i `Contact Points`
5. Przejdź do `Create contact point`
6. Nazwij go `Alert`
7. Z pola wybieralnego `Integration` wybierz `webhook`
8. Przetestuj (oraz zweryfikuj przychodzący alert po stronie *webhook.site*)
9. Zapisz webhook
10. Przejdź teraz do `Alert rules` który znajdziesz po lewej stronie pod polem `Alerting`
    1. Kliknij `Add alert rule`
    2. Nazwij ją `Ruch sieciowy przekroczony`
    3. W sekcji 2: `Define query and alert condition`
       1. Kliknij przełącznik z prawej strony: `advanced options`
       2. Wykorzystajmy do tego alertu używane wcześniej zapytanie z Prometheus:

      ```text
      sum(rate(tns_request_duration_seconds_count[5m])) by(route)
      ```

      1. W okienku C (Threshold) zmodyfikuj wartość `0` na wartość `0.2`
      2. Naciśnij przycisk `Preview` by przestestować, czy dane kondycje nie przekraczają standardowego zachowania aplikacji (wszystkie powinny być oznaczone w sekcji C jako `Normal`)
    4. W sekcji 3: `Set evaluation behavior`
       1. Stwórz nowy folder `New folder` i nazwij go: `traffic`
       2. Dodaj również grupę `New evaluation group` i nazwij ją: `traffic` i wybierz dla jej `10 seconds` okresu ewaluacji
       3. Pending period ustaw na `None`
    5. W sekcji 4: `Configure labels and notifications`
       1. Wybierz Contact Point: `Alert`
 11. Zapisz używając `Save rule and exit` w górnej części strony
 12. Przetestuj teraz czy ruch sieciowy wzbudzi stworzoną przez ciebie regułę:
     1. Przejdź na zakładkę przykładowej aplikacji (przykładowo wykonaj dużo operacji głosowania na stronę) - około 50 głosów klikniętych powinno wystarczyć
     2. Zaobserwuj, iż reguła notyfikacji została dostarczona poprawnie na adres [webhook.site](https://webhook.site/)
     3. Przejdź na koniec na zakładkę Grafany: `Alerting` -> `Alerting rules`, by sprawdzić jak grafana notyfikuje o incydencie (rozwiń stworzony alert o nazwie `Alert`)
     4. Ostatecznie sprawdź jeszcze wykres na dashboardzie - powinien wyglądać o wiele ciekawiej

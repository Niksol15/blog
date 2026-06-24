---
title: "Всі (92) способи надрукувати \"Hello World\" у C++26"
date: "2026-06-18"
description: "Від std::cout до io_uring, inline assembly та compile-time трюків - 92 різні способи надрукувати Hello World у C++26, майже всі з яких зрештою зводяться до одного write(2)."
tags:
  - C++
  - Linux
  - POSIX
  - Системне програмування
  - io_uring
categories:
  - Програмування
---

Чи бувало у вас таке, що в неділю ввечері вас починає мучити питання: "А скільки ж все-таки способів надрукувати `"Hello World"` у консоль в C++?".
Сподіваюсь, ні, бо це вже як мінімум профдеформація. Але я задався таким питанням, і зрозумів, що немає жодного джерела,
яке відповідає на нього. Тому я вирішив зробити таке джерело сам.

Оскільки C++ - це тепер не просто мова програмування, а ще й мова метапрограмування, розглянемо два окремі випадки:
друк `"Hello World"` в рантаймі та на етапі компіляції.

Моєю метою було порахувати всі _справді різні_ способи. І це складніше, ніж здається.
Бо врешті майже все зводиться до чогось, що викликає `write(2)` через різну кількість шарів абстракцій,
причому часто різниця між способами мікроскопічна. Я використав наступний підхід:

```text
Спосіб - це окрема іменована сутність, яка напряму друкує рядок.
```

Весь код протестований на Fedora 44 (ядро 7.0, x86-64) зі стеком GCC 16.1, Clang 22.1, glibc 2.43.
Усі сніпети лежать [в репозиторії блогу](https://github.com/Niksol15/blog/tree/master/resources/cpp-hello-world),
разом зі скриптами для запуску.

Я тут розглянув як методи, що чітко відповідають C++26, так і методи, які працюють специфічно на Linux x86-64.

---

## Рантайм

Спочатку код, який повністю відповідає C++26, потім код, який працює тільки на POSIX системах, далі POSIX розширення, а наостанок Linux-специфічний код.

---

### Стандартний C++

#### Канонічний набір

Це ті способи, які зустрічаються в 99% випадків.

**#1. `std::cout::operator<<`**

```cpp
#include <iostream>

int main()
{
    std::cout << "Hello World\n";
}
```

Всім відомо, що `\n` сам по собі не флашить буфер. Якщо треба flush, то треба замінити `\n` на `std::endl`:

```cpp
std::cout << "Hello World" << std::endl;   // '\n' + flush
```

або викликати явний flush():

```cpp
std::cout.flush();
```

Чомусь у більшості туторіалів для початківців використовують `std::endl`.
Хоча, на мою думку, в більшості випадків він не потрібен, і краще використати просто `\n`.

**#2. `printf()`**

```cpp
#include <cstdio>

int main()
{
    printf("Hello World\n");
}
```

`printf` парсить format string у пошуках `%`, тому технічно тут є зайва робота.
Хоча компілятори давно це [оптимізують](https://godbolt.org/z/4fx37shj7) до `puts("Hello World")`.

**Відступ про `std::ios_base::sync_with_stdio(false)`**

Маленький відступ, знайомий людям, що займались competitive programming.
"Нове" iostream-based API в C++ додавали із сумісністю з C в пріоритеті.
У тому плані, що код, який вже використовував `printf` (або будь-яке інше C stdio I/O) міг без зайвих налаштувань почати використовувати `std::cout` з гарантованим очікуваним порядком виводу. Це важливо, бо C та C++ код часто лінкується разом.

Тому, за замовчуванням, стандартні C++ потоки синхронізовані з відповідними C потоками: `std::cout` з `stdout`, `std::cin` з `stdin`, `std::cerr` і `std::clog` з `stderr` (плюс їхні wide-аналоги). Коли синхронізація увімкнена, C++ потоки можуть ділити буфер з відповідним `FILE*`. Два послідовні різні виклики `operator<<` та `printf` відпрацюють у тому порядку, в якому написані. Тут, до речі, на мою думку, C++ ламає принцип zero-overhead.

Цю поведінку можна виключити, викликавши `std::ios_base::sync_with_stdio(false)`.
Важливо: виклик має бути до будь-яких I/O операцій, інакше поведінка implementation-defined.
Після цього C++ потоки отримують власний незалежний буфер.
Але якщо після цього міксувати `operator<<` та `printf`, порядок виведення більше не буде гарантований,
бо кожен механізм буферизує незалежно.

**#3. `fprintf()`**

```cpp
#include <cstdio>

int main()
{
    fprintf(stdout, "Hello World\n");
}
```

До речі, стандартом напряму чітко визначено, що `printf` - це `fprintf(stdout, ...)`.

**#4. `puts()`**

```cpp
#include <cstdio>

int main()
{
    puts("Hello World");
}
```

Як на мене, це найкращий спосіб, коли треба просто надрукувати рядок у термінал без форматування.
Функція сама додає `\n`.

**#5. `fputs()`**

```cpp
#include <cstdio>

int main()
{
    fputs("Hello World\n", stdout);
}
```

На відміну від `puts()`, ця функція сама не додає `\n`.

**#6. `std::print()` - C++23**

```cpp
#include <print>

int main()
{
    std::print("Hello World\n");
}
```

Функція побудована на базі `std::format`, що є типобезпечним. Також вона не тягне за собою весь iostream.
На мою думку, це те, що мало бути в мові вже дуже давно, а не з 2023 року.

Маленька деталь: це перевантаження `std::print` пише в `FILE* stdout`, а не в `std::cout`.
Тут можна побачити, що комітет розуміє, що `iostream` не був дуже вдалим рішенням у ретроспективі.

**#7. `std::println()` - C++23**

```cpp
#include <print>

int main()
{
    std::println("Hello World");
}
```

Те саме, що `std::print`, але з автоматично доданим `\n` наприкінці.

**#8. `std::print(stdout, …)` - C++23**

```cpp
#include <cstdio>
#include <print>

int main()
{
    std::print(stdout, "Hello World\n");
}
```

Це перевантаження приймає будь-який `FILE*`.

**#9. `std::println(stdout, …)` - C++23**

```cpp
#include <cstdio>
#include <print>

int main()
{
    std::println(stdout, "Hello World");
}
```

Те саме, що `#8`, але з автоматично доданим `\n` наприкінці.

**#10. `std::print(std::ostream&, …)` - C++23**

```cpp
#include <iostream>
#include <print>

int main()
{
    std::print(std::cout, "Hello World\n");
}
```

А це перевантаження приймає `std::ostream&`.

**#11. `std::println(std::ostream&, …)`**

```cpp
#include <iostream>
#include <print>

int main()
{
    std::println(std::cout, "Hello World");
}
```

Те саме, що `#10`, але з автоматично доданим `\n` наприкінці.

#### Рівень нижче: байти й символи

**#12. `std::ostream::write()`**

```cpp
#include <iostream>
#include <string_view>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    std::cout.write(msg.data(), msg.size());
}
```

Прямий запис `n` байтів. Працює на будь-якому `std::ostream`, і все аналогічно йде через буфер.

**#13. `std::streambuf::sputn()`**

```cpp
#include <iostream>
#include <string_view>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    std::cout.rdbuf()->sputn(msg.data(), msg.size());
}
```

Те, що `std::cout.write` робить усередині. `std::ostream::write` спершу створює sentry (перевіряє стан потоку), а тоді викликає `sputn` на `std::streambuf`.

**#14. `std::ostream::put()`**

```cpp
#include <iostream>
#include <string_view>

int main()
{
    for (char c : std::string_view("Hello World\n"))
    {
        std::cout.put(c);
    }
}
```

Це кладе в буфер по одному символу за раз. У ядро це піде одним `write` під час флашу.

**#15. `std::streambuf::sputc()`**

```cpp
#include <iostream>
#include <string_view>

int main()
{
    for (char c : std::string_view("Hello World\n"))
    {
        std::cout.rdbuf()->sputc(c);
    }
}
```

Те саме, що `sputn`, тільки посимвольно, і рівно те, як `cout.put` імплементовано всередині.

**#16. `fwrite()`**

```cpp
#include <cstdio>
#include <string_view>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    fwrite(msg.data(), 1, msg.size(), stdout);
}
```

**#17. `putchar()`**

```cpp
#include <cstdio>
#include <string_view>

int main()
{
    for (char c : std::string_view("Hello World\n"))
    {
        putchar(c);
    }
}
```

**#18. `putc()`**

```cpp
#include <cstdio>
#include <string_view>

int main()
{
    for (char c : std::string_view("Hello World\n"))
    {
        putc(c, stdout);
    }
}
```

Те саме, що `putchar`, але з явним `FILE*`. `putc` за стандартом _може_ бути макросом.

**#19. `fputc()`**

```cpp
#include <cstdio>
#include <string_view>

int main()
{
    for (char c : std::string_view("Hello World\n"))
    {
        fputc(c, stdout);
    }
}
```

Те саме, що `putc`, але **гарантовано функція**.

#### Форматування як окрема операція: `<format>`

`std::cout << std::format("…")` я не рахую, бо по суті це просто `operator<<`.

**#20. `std::format_to()`**

```cpp
#include <format>
#include <iostream>
#include <iterator>
#include <string_view>

int main()
{
    constexpr std::string_view message = "Hello World";
    std::format_to(std::ostream_iterator<char>(std::cout), "{}\n", message);
}
```

Форматує одразу в output iterator.

**#21. `std::format_to_n()`**

```cpp
#include <format>
#include <iostream>
#include <iterator>
#include <string_view>

int main()
{
    constexpr std::string_view message = "Hello World";
    // +1 accounts for the '\n' appended by the format string
    constexpr auto cap = message.size() + 1;
    std::format_to_n(std::ostream_iterator<char>(std::cout), cap, "{}\n", message);
}
```

Те саме, що `format_to`, але з обмеженням на кількість символів. Використовується, коли повідомлення
форматується в буфер фіксованого розміру.

#### iostream + алгоритми STL

Навіщо писати цикл, якщо можна зібрати докупи три шаблони?

**#22. STL-алгоритм + `output iterator`**

```cpp
#include <algorithm>
#include <iostream>
#include <iterator>
#include <string_view>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    std::ranges::copy(msg, std::ostream_iterator<char>(std::cout));
}
```

Замість `std::ranges::copy` тут так само спрацюють `std::copy`, `std::for_each`, `std::ranges::for_each`.

А ось важлива деталь: який саме output iterator взяти, визначає, через що будуть передаватись байти. `std::ostream_iterator<char>` передає кожен символ через `operator<<` (тобто formatted output, як у #1). А `std::ostreambuf_iterator<char>` пише **прямо в streambuf** через `sputc`, оминаючи весь шар форматування (як `sputc`, #15):

```cpp
std::ranges::copy(msg, std::ostreambuf_iterator<char>(std::cout));
```

#### А якщо в `cout` пишуть кілька потоків одночасно?

**#23. `std::osyncstream` - C++20**

```cpp
#include <iostream>
#include <syncstream>

int main()
{
    std::osyncstream(std::cout) << "Hello World\n";
}
```

`osyncstream` накопичує output у власному буфері й **атомарно передає його в цільовий потік під час деструкції**.
Це зроблено тому, що якщо у вас кілька потоків пишуть у `ostream` без синхронізації, то їхні рядки можуть перемішатися.

Виклик printf() атомарний (stdio бере лок FILE* на час виклику), і `std::cout::operator<<` на практиці теж, бо libstdc++ за замовчуванням ходить через той самий лок. Щоправда, стандарт атомарності одного `<<` не гарантує, а гарантує лише лише відсутність data race.
Але `std::cout << "Hello" << "World"` - це вже 2 окремі виклики оператора, і між ними може вклинитись
`std::cout::operator<<`, виконаний в іншому потоці.

`std::osyncstream` склеює всю послідовність `operator<<` в один атомарний виклик. По суті це те саме, що зібрати рядок у `std::ostringstream`, а потім один раз зробити `std::cout << stream.str()`.

#### `stderr` і широкі потоки

**#24. `std::cerr::operator<<`**

```cpp
#include <iostream>

int main()
{
    std::cerr << "Hello World\n";
}
```

Той самий `operator<<`, але інший потік. `std::cerr` - це стандартний потік помилок (дескриптор 2 на Linux).
Існує він для зручності, щоб можна було легко розділяти через перенаправлення потоку помилки і звичайний output.

У `cerr` виставлений прапор `unitbuf`, тому він флашиться після **кожної** операції виведення.
Бо зазвичай ми хочемо дізнатися про помилку одразу, як вона виникла, а не коли буфер
вирішить зафлешитись.

**#25. `std::clog::operator<<` у stderr, але з буфером**

```cpp
#include <iostream>

int main()
{
    std::clog << "Hello World\n";
}
```

Той самий `cerr`, але **без** виставленого `unitbuf`. Задуманий він для діагностичних повідомлень,
які не є "терміновими".

Тут можна було ще окремо зарахувати кожен перелічений вище метод `cout` ще 2 рази (один для cerr, один для clog),
але я не буду.

**#26. `fprintf(stderr, …)` - C stdio у stderr**

```cpp
#include <cstdio>

int main()
{
    fprintf(stderr, "Hello World\n");
}
```

Аналогічна функціональність до `cerr`, але в `cstdio`.

**#27-29. Широкі потоки: `std::wcout`, `std::wcerr`, `std::wclog`**

```cpp
#include <iostream>

int main()
{
    std::wcout << L"Hello World\n";
}
```

Ця трійця віддзеркалює `cout`/`cerr`/`clog`: `wcout` пише в `stdout`, `wcerr`/`wclog` - у `stderr`. Різниця у тому, що широкі потоки приймають `wchar_t` і конвертують його в `char` через `codecvt` локалі, щось типу `use_facet<codecvt<...>>(getloc())`. Для ASCII конвертація тривіальна. На виході той самий `write(1, "Hello World\n", 12)`.

Взагалі локалі - це одна з проблем C++, яка, серед іншого, особливо боляче вистрілила в регулярних виразах. Є мем, що для деяких регулярних виразів швидше запустити Python script, ніж чекати, поки відпрацює `std::regex`. Це черговий приклад порушення принципу zero-overhead.

**#30-33. Широкі потоки: нижчі точки входу (`wcout.write` тощо)**

Усе, що має `cout` (#12-#15), має й `wcout`, просто шаблонізоване на `wchar_t`.
Наступні чотири методи відповідають #12-#15: `wcout.write` (#30), `wcout.rdbuf()->sputn` (#31), `wcout.put` (#32), `wcout.rdbuf()->sputc` (#33). Тут можна було б ще зарахувати `wcerr`/`wclog` і відповідні методи окремо, але я не буду.

**#34-39. Широкий C stdio: `wprintf` і компанія**

```cpp
#include <cwchar>

int main()
{
    wprintf(L"Hello World\n");
}
```

Аналогічно до iostream, `cstdio` має власну шістку широких функцій (точніше, навпаки): `wprintf` (#34), `fwprintf` (#35), `fputws` (#36), `putwchar` (#37), `putwc` (#38), `fputwc` (#39). Усі конвертують `wchar_t` через `wcrtomb` локалі. Для ASCII на виході знову `write(1, …, 12)`.

#### Нехай надрукує інший процес (стандартний C)

**#40. `system()`**

```cpp
#include <cstdlib>

int main()
{
    return system("echo Hello World");
}
```

Це запускає `echo`, яке друкує "Hello World".
Так робити не треба, бо це довго і небезпечно через shell injection.

#### output як побічний ефект діагностики

Тут "Hello World" опиняється в терміналі не тому, що ми його _друкуємо_, а тому, що бібліотека чи рантайм ним _повідомляє_ про щось у stderr.

**#41. Непійманий `throw`**

```cpp
#include <stdexcept>

int main()
{
    throw std::runtime_error("Hello World");
}
```

Виняток ніхто не ловить -> викликається `std::terminate` -> рантайм друкує `what()` у stderr і вбиває процес:

```text
terminate called after throwing an instance of 'std::runtime_error'
  what():  Hello World
```

Це вже хак, але технічно наш рядок опинився в терміналі.
Точний текст цього повідомлення implementation-defined. Його видає стандартна бібліотека.

**#42. `assert()`**

```cpp
#include <cassert>

int main()
{
    assert(false && "Hello World");
}
```

```text
a.out: hello.cpp:5: int main(): Assertion `false && "Hello World"' failed.
```

Працює, тільки поки не задефайнено `NDEBUG`. Інакше `assert` розкривається у ніщо і Hello World зникає.

**#43-45. `contract_assert`, `pre`, `post` - C++26 Contracts**

```cpp
// build with -fcontracts
int main()
{
    contract_assert(false && "Hello World");
}
```

Три нові конструкції з Contracts в C++26. `contract_assert` - це еволюція `assert`.

```cpp
int f(int x) pre(false && "Hello World") { return x; }    // #44
int g(int x) post(false && "Hello World") { return x; }   // #45
```

Усі три проходять через **обробник порушень контракту**, а не через `abort`, і його поведінку можна перемикати
прапором компілятора `-fcontract-evaluation-semantic=[ignore|observe|enforce|quick_enforce]`.
Загалом система дуже гнучка і заслуговує на окремий топік, яких зараз безліч.
GCC 16 (з `-fcontracts`) під дефолтним `enforce` друкує в stderr:

```text
contract violation in function int main() at hello.cpp:4: false && "Hello World"
[assertion_kind: assert, semantic: enforce, mode: predicate_false, terminating: yes]
terminate called without an active exception
```

Ключова відмінність між трьома - це поле `assertion_kind`: `assert`, `pre` чи `post`.
Поки що Contracts вміє лише GCC. В стабільній версії Clang їх ще немає.

**#46. `perror()`**

```cpp
#include <cerrno>
#include <cstdio>

int main()
{
    errno = 0;
    perror("Hello World");
}
```

`perror` друкує в stderr рядок, двокрапку й опис поточного `errno`. Оскільки у прикладі `errno` обнулено, то опис буде "Success":

```text
Hello World: Success
```

Хак? Хак. Але що ви мені зробите)

> **Проміжний підсумок: 46 способів.** І це все стандартний C++26.

---

### Бонус

Хочеться ще розглянути методи, які не належать до стандарту, але також можуть використовуватись.

#### POSIX

Код, що відповідає стандарту POSIX та працює на всіх системах, що його реалізують.

##### Прямий I/O повз буфери

**#47. `write()`**

```cpp
#include <string_view>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    write(STDOUT_FILENO, msg.data(), msg.size());
}
```

Це той самий `write(2)`, до якого зводиться майже все інше в цій статті.

**#48. `writev()`**

```cpp
#include <iterator>
#include <sys/uio.h>
#include <unistd.h>

int main()
{
    char hello[] = "Hello ";
    char world[] = "World\n";
    iovec iov[] = {
        { hello, sizeof(hello) - 1 },
        { world, sizeof(world) - 1 },
    };
    writev(STDOUT_FILENO, iov, std::size(iov));
}
```

Збирає дані з кількох окремих буферів в один **атомарний** системний виклик.

**#49. `dprintf()`**

```cpp
#include <cstdio>
#include <unistd.h>

int main()
{
    dprintf(STDOUT_FILENO, "Hello World\n");
}
```

`printf` для файлових дескрипторів. Форматує як `printf`, але пише напряму у fd, без `FILE*`.

А тепер почесна згадка, яка _не_ йде в залік. Є ще `pwrite()` - позиціонований запис за зміщенням:

```cpp
pwrite(STDOUT_FILENO, "Hello World\n", 12, 0);
```

Проблема в тому, що `pwrite` вимагає _seekable_ дескриптор. Якщо записувати у файл
(`./a.out > out.txt`), то це спрацює. А якщо в термінал чи pipe, то буде `ESPIPE` (`Illegal seek`), і нічого не надрукується, тому цей спосіб не зараховується.

##### Через файлову систему

До дескриптора можна дотягнутися й через файлову систему, просто відкривши потрібний шлях.

**#50. `open("/dev/tty")` + `write()`**

```cpp
#include <fcntl.h>
#include <string_view>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    int fd = open("/dev/tty", O_WRONLY);
    write(fd, msg.data(), msg.size());
    close(fd);
}
```

`/dev/tty` - це **контролюючий термінал** процесу, незалежно від того, куди перенаправлено stdout. Запустіть `./a.out > /dev/null`, і ви все одно побачите "Hello World" у терміналі, бо він пише повз перенаправлення. Цей спосіб вимагає наявності контролюючого термінала. Під час тесту в headless-середовищі без tty `open` повертає `-1`, тому я перевіряв його під справжнім псевдотерміналом.

Споріднена цікавинка, що не йде в перелік, бо вже й не працює: `ioctl(fd, TIOCSTI, &c)` додає символ не у _output_ термінала, а в його чергу **вводу**. Сучасні ядра вимикають `TIOCSTI` за замовчуванням (`CONFIG_LEGACY_TIOCSTI`) і вимагають `CAP_SYS_ADMIN`.

##### Нехай надрукує інший процес (POSIX)

**#51. `execlp()`**

```cpp
#include <unistd.h>

int main()
{
    execlp("echo", "echo", "Hello World", static_cast<char*>(nullptr));
}
```

Це замінює процес на `echo`. Після вдалого `exec` "нашого" коду буквально більше не існує.

**#52. `fork()` + `execvp()`**

```cpp
#include <sys/wait.h>
#include <unistd.h>

int main()
{
    if (fork() == 0)
    {
        char arg0[] = "echo";
        char arg1[] = "Hello World";
        char* args[] = { arg0, arg1, nullptr };
        execvp("echo", args);
        _exit(127);  // only reached if exec failed
    }
    wait(nullptr);
}
```

Класичний Unix-патерн і принципова відмінність від попереднього: ми форкаємось, child стає `echo`, а **parent залишається живим** і чекає на завершення виконання child. Зверніть увагу на `_exit(127)` (не `exit()`) після `exec`. Якщо `exec` раптом зафейлиться, то child не має провалитися далі в parent логіку.

Ви можете мене спитати. Чому `exec` способів лише два, а не шість? Сімейство `exec*` (`execl`, `execlp`, `execle`, `execv`, `execvp`, `execve`) різниться тільки тим, як передаються аргументи. Усі вони зводяться до одного системного виклику `execve`. Тому я вирішив не нагліти тут і не рахувати види `exec`, а рахувати тільки **патерн роботи з процесом**: замінити себе (#51) чи форкнутись і пережити child (#52).

**#53. `posix_spawn()`**

```cpp
#include <spawn.h>
#include <sys/wait.h>

extern char** environ;

int main()
{
    char arg0[] = "/bin/echo";
    char arg1[] = "Hello World";
    char* args[] = { arg0, arg1, nullptr };

    pid_t pid{};
    posix_spawn(&pid, "/bin/echo", nullptr, nullptr, args, environ);
    waitpid(pid, nullptr, 0);
}
```

Стандартизована альтернатива зв'язці `fork` + `exec` в одному виклику. На додачу, у випадку, коли `fork` дорогий, `posix_spawn` може бути ефективнішим, бо реалізований через легші примітиви (на Linux - через `clone`/`vfork`).

Чому `fork` може бути дорогим? Інтуїтивно `fork` майже безкоштовний, через те, що він не копіює фізичну пам'ять, бо працює через copy-on-write (COW). Водночас його вартість залежить від розміру **page tables**: ядро мусить продублювати всі батьківські PTE, позначити кожну writable сторінку як read-only для COW і зробити TLB shootdown по всіх ядрах, на яких виконувався процес. Для процесу з великим адресним простором це вже відчутно. `posix_spawn` через `vfork`/`clone(CLONE_VM|CLONE_VFORK)` усього цього уникає: child позичає адресний простір parent, тож дублювати таблиці сторінок не треба.

##### Асинхронний input-output

**#54. `aio_write()` - POSIX AIO**

```cpp
// link with -lrt
#include <aio.h>
#include <unistd.h>

int main()
{
    static char msg[] = "Hello World\n";

    aiocb cb{};
    cb.aio_fildes = STDOUT_FILENO;
    cb.aio_buf = msg;
    cb.aio_nbytes = sizeof(msg) - 1;

    aio_write(&cb);

    const aiocb* list[] = { &cb };
    aio_suspend(list, 1, nullptr);  // block until the write completes
}
```

Асинхронний input-output. Це ставить запис у чергу й чекає завершення через `aio_suspend`.
На glibc POSIX AIO реалізований пулом helper-тредів, що роблять звичайний синхронний I/O: на не-seekable дескриптор (термінал, pipe) тред намагається зробити `pwrite`, що призводить до `ESPIPE`, а тоді робить fall-back на той самий `write(1, "Hello World\n", 12)`.

**#55. `lio_listio()` - батч POSIX AIO**

```cpp
// link with -lrt
#include <aio.h>
#include <unistd.h>

int main()
{
    static char msg[] = "Hello World\n";

    aiocb cb{};
    cb.aio_fildes = STDOUT_FILENO;
    cb.aio_buf = msg;
    cb.aio_nbytes = sizeof(msg) - 1;
    cb.aio_lio_opcode = LIO_WRITE;

    aiocb* list[] = { &cb };
    lio_listio(LIO_WAIT, list, 1, nullptr);
}
```

Аналогічно до попереднього методу, але замість однієї операції цей метод приймає цілий список `aiocb` і сабмітить його одним викликом. `LIO_WAIT` ще змушує цей потік заблокуватись, доки весь список не відпрацює.

І ще одна почесна згадка, яка не йде в залік: `send()`.

```cpp
send(STDOUT_FILENO, "Hello World\n", 12, 0);
```

`send` - це `write` для сокетів. Якщо ваш stdout - це сокет (наприклад, програму запустили з-під `inetd` чи `socat`), це спрацює. Я перевірив, підставивши сокет на дескриптор 1, і це спрацювало. Але в звичайному терміналі це призводить до `ENOTSOCK`. Тому як окремий спосіб - не зараховую.

##### `_unlocked` - ті самі функції без внутрішнього локу

Кожен виклик stdio за замовчуванням блокує `FILE*` заради потокобезпечності. Родина `_unlocked` блокування не робить, у цьому вся різниця. Це швидше, але треба гарантувати, що в цей потік ніхто інший не пише одночасно.

`putc_unlocked`/`putchar_unlocked` - це частина POSIX. Решта (зокрема всі широкі) - це розширення glibc, але перелічу я все тут, бо, знову ж таки, що ви мені зробите.

**#56-60. Вузькі:** `putchar_unlocked` (#56), `putc_unlocked` (#57), `fputc_unlocked` (#58), `fputs_unlocked` (#59), `fwrite_unlocked` (#60) - двійники #17/#18/#19/#5/#16 без локу.

```cpp
#include <cstdio>

int main()
{
    fputs_unlocked("Hello World\n", stdout);
}
```

**#61-64. Широкі (glibc):** `fputws_unlocked` (#61), `putwchar_unlocked` (#62), `putwc_unlocked` (#63), `fputwc_unlocked` (#64) - двійники #36/#37/#38/#39 без локу.

```cpp
#include <cwchar>

int main()
{
    fputws_unlocked(L"Hello World\n", stdout);
}
```

> **Проміжний підсумок: 64 способи.**

---

#### Розширення

POSIX - це не вся Unix-екосистема. Є ще купа розширень, яких немає в жодному стандарті.

##### `<err.h>` (BSD) і `<error.h>` (GNU)

BSD-родина `<err.h>` дає чотири такі функції, а GNU-розширення `<error.h>` дає ще дві.

**#65-68. `err()`, `warn()`, `errx()`, `warnx()`** - BSD `<err.h>`

```cpp
#include <err.h>

int main()
{
    warnx("Hello World");   // "<progname>: Hello World" to stderr
}
```

Четвірка різниться двома моментами: чи додавати `: strerror(errno)` (як `perror`) і чи виходити з програми. `warn`/`err` додають `strerror`, `warnx`/`errx` - ні. `err`/`errx` наприкінці викликають `exit()`, `warn`/`warnx` - ні.

**#69-70. `error()`, `error_at_line()`** - GNU `<error.h>`

```cpp
#include <error.h>

int main()
{
    error(0, 0, "Hello World");   // "<progname>: Hello World" to stderr
}
```

`error(status, errnum, …)` за `errnum != 0` додає `strerror`, за `status != 0` виходить. `error_at_line` робить те саме, плюс додає префікс `файл:рядок:`.

> **Проміжний підсумок: 70 способів.**

---

#### Суто Linux

##### Через procfs

`stdout` - це файл, і його можна відкрити за шляхом у файловій системі. На Linux `/dev/stdout` - це симлінк на `/proc/self/fd/1`. Сам POSIX цього шляху не стандартизує. На BSD, наприклад, `/dev/stdout` теж є, але через інший механізм.

**#71. `std::ofstream("/dev/stdout")`**

```cpp
#include <fstream>

int main()
{
    std::ofstream("/dev/stdout") << "Hello World\n";
}
```

Те саме можна зробити мовою C через `fopen("/dev/stdout", "w")` + `fprintf` або через інші шляхи до того ж дескриптора: `/dev/fd/1` чи `/proc/self/fd/1`. Я зараховую це як 1 метод "відкрити fd через файлову систему".

##### syscall

**#72. `syscall(SYS_write, …)`**

```cpp
#include <string_view>
#include <sys/syscall.h>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    syscall(SYS_write, 1, msg.data(), msg.size());
}
```

Це обходить навіть libc обгортку `write()` і викликає системний виклик за його номером.

**#73. Inline assembly - `x86-64`**

```cpp
int main()
{
    const char msg[] = "Hello World\n";
    asm volatile(
        "mov $1, %%rax\n"   // syscall number: write
        "mov $1, %%rdi\n"   // fd: stdout
        "mov %0, %%rsi\n"   // buf: msg
        "mov %1, %%rdx\n"   // count: msg length, without the '\0'
        "syscall"
        :
        : "r"(msg), "i"(sizeof(msg) - 1)
        : "rax", "rdi", "rsi", "rdx", "rcx", "r11", "memory");
}
```

Найнижчий рівень, доступний з C++: сама інструкція `syscall`. `rcx` і `r11` у списку clobber-ів не випадкові: інструкція `syscall` затирає їх, зберігаючи в них RIP і RFLAGS відповідно. `memory` у clobber-ах каже компілятору не тримати значення пам'яті в регістрах через межу asm.

##### Перенесення даних силами ядра

Наступні три способи цікаві тим, що дані рухаються до `stdout` **усередині ядра**, майже не торкаючись нашого userspace, а фінальний output робить не `write`, а власний системний виклик.

**#74. `sendfile()` з `memfd_create()`**

```cpp
#include <string_view>
#include <sys/mman.h>
#include <sys/sendfile.h>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    constexpr auto len = msg.size();

    int fd = memfd_create("hello", 0);  // "hello" is just a debug label, not output
    write(fd, msg.data(), len);
    lseek(fd, 0, SEEK_SET);
    sendfile(STDOUT_FILENO, fd, nullptr, len);
    close(fd);
}
```

`memfd_create` робить анонімний файл з ім'ям "hello", що живе в RAM і видимий в `/proc/self/fd`. `write` заповнює цей файл, а тоді `sendfile` копіює дані з нього в stdout **в kernel-space**. Для більшого приколу, цей memfd можна заповнити не через `write`, а через `mmap` + `memcpy`.

**#75. `splice()` через pipe**

```cpp
#include <fcntl.h>
#include <string_view>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";
    constexpr auto len = msg.size();

    int pfd[2]{};
    pipe(pfd);
    write(pfd[1], msg.data(), len);
    splice(pfd[0], nullptr, STDOUT_FILENO, nullptr, len, 0);
    close(pfd[0]);
    close(pfd[1]);
}
```

`splice` переміщує дані між дескрипторами через ядро, без копіювання в userspace. Один з дескрипторів обов'язково має бути pipe. Output у `stdout` тут робить сам системний виклик `splice`. Є схожі методи типу `vmsplice` (мапить сторінки userspace в pipe) і `tee` (дублює дані між двома pipe).

Ще є `copy_file_range`, який теж копіює дані між двома дескрипторами, але обидва дескриптори мусять бути **звичайними файлами**. У термінал чи pipe цей метод копіювати не вміє.

**#76. `io_uring`**

```cpp
// link with -luring
#include <liburing.h>
#include <string_view>
#include <unistd.h>

int main()
{
    constexpr std::string_view msg = "Hello World\n";

    io_uring ring{};
    io_uring_queue_init(1, &ring, 0);

    io_uring_sqe* sqe = io_uring_get_sqe(&ring);
    io_uring_prep_write(sqe, STDOUT_FILENO, msg.data(), msg.size(), 0);
    io_uring_submit(&ring);

    io_uring_cqe* cqe = nullptr;
    io_uring_wait_cqe(&ring, &cqe);
    io_uring_cqe_seen(&ring, cqe);
    io_uring_queue_exit(&ring);
}
```

Найсучасніший Linux I/O API. Submission queue, completion queue, buffer ring, спільні між ядром і userspace - усе це придумано, щоб максимально ефективно робити велику кількість I/O операцій. Для "Hello World", як бачимо, воно також підходить. Тут немає синхронного `write` взагалі. I/O ядро виконує з нашого SQE, а ми лише сабмітимо й чекаємо завершення. Це чудово видно в `strace`: жодного `write(1, …)` там немає, натомість лише `io_uring_setup` і `io_uring_enter`, усередині якого ядро саме й робить запис:

```text
$ strace -e io_uring_setup,io_uring_enter,write ./io-uring
io_uring_setup(1, {...}) = 3
io_uring_enter(3, 1, 0, 0, NULL, 8) = 1     # SQE submitted; the write happens in-kernel
```

> **Підсумок рантайму: 76 способів.**

---

## Compile-time - програма навіть не запускається

У цьому розділі розглянемо, як змусити "Hello World" з'явитися під час **компіляції**, а не виконання.

### Стандартний C++

**#77. `static_assert` - C++11**

```cpp
static_assert(false, "Hello World");
```

```text
error: static assertion failed: Hello World
```

Найбільш прямий спосіб змусити компілятор надрукувати те, що ти хочеш. Також це можна відкласти до інстанціації шаблону через value-dependent вираз:

```cpp
template <int N>
struct HelloWorld
{
    static_assert(N != N, "Hello World");
};

template struct HelloWorld<42>;
```

`N != N` залежить від параметра шаблону, тому перевірку відкладено до інстанціації. Сучасні GCC/Clang завдяки CWG2518 уже не падають і на незалежному `static_assert(false)`.

**#78. `[[deprecated]]` - C++14**

```cpp
[[deprecated("Hello World")]]
void f() {}

int main() { f(); }
```

Компіляція проходить, але з попередженням:

```text
warning: 'void f()' is deprecated: Hello World [-Wdeprecated-declarations]
```

**#79. `[[nodiscard("…")]]` - C++20**

```cpp
[[nodiscard("Hello World")]]
int f() { return 0; }

int main() { f(); }
```

Компіляція проходить, але якщо проігнорувати значення, що повертається (а ми саме це й робимо), то буде попередження:

```text
warning: ignoring return value of 'int f()', declared with attribute 'nodiscard': 'Hello World' [-Wunused-result]
```

Можливість додавати причину для `[[nodiscard]]` додали в C++20, сам `[[nodiscard]]` в C++17.

**#80. `= delete("…")` - C++26**

```cpp
void f() = delete("Hello World");

int main() { f(); }
```

```text
error: use of deleted function 'void f()': Hello World
```

Можливість указати причину видалення функції прийняли аж у C++26, GCC 16 це вже підтримує.

**#81. `throw` під час компіляції - C++26**

У C++26 кидати винятки можна вже **під час компіляції**, і якщо виняток виходить за межі constexpr-виразу, то компілятор зобов'язаний це продіагностувати. GCC 16 при цьому виводить `what()` просто в текст помилки:

```cpp
#include <stdexcept>

constexpr int hello() { throw std::runtime_error("Hello World"); }

constexpr int x = hello();   // forces constant evaluation -> the throw escapes
```

```text
error: uncaught exception of type 'std::runtime_error'; 'what()': 'Hello World'
```

Фактично, компілятори вже вміють виконувати велику частину C++ коду під час компіляції.
Невеличке застереження: це поки що вміє лише GCC. Clang 22 ще не реалізував кидання винятків у константних обчисленнях ([P3068](https://wg21.link/p3068)). Він просто відкидає `throw` як неконстантний вираз, не доходячи до `what()`.

**#82. `#pragma message`**

```cpp
#pragma message("Hello World")
```

```text
note: '#pragma message: Hello World'
```

**#83. `#warning` - C++23**

```cpp
#warning "Hello World"
```

```text
warning: #warning "Hello World" [-Wcpp]
```

До C++23 це було розширенням GCC і Clang; тепер це стандарт (P2437R1).

**#84. `#error` - C++98**

```cpp
#error "Hello World"
```

```text
error: #error "Hello World"
```

Стандартна директива препроцесора з C++98.

**#85. `#include "Hello World"`**

```cpp
#include "Hello World"
int main() {}
```

```text
fatal error: Hello World: No such file or directory
```

Ще один output як побічний ефект діагностики, тільки тепер від препроцесора. Препроцесор шукає файл із таким іменем, не знаходить і падає з фатальною помилкою. Ім'я в лапках може містити пробіл, тож `"Hello World"` - це цілком легальний хедер. Теж трохи хак, але що поробиш)

### Компілятор-специфічні

**#86. `__attribute__((warning(...)))` - лише GCC**

```cpp
__attribute__((warning("Hello World")))
void f() {}

int main() { f(); }
```

```text
warning: call to 'f' declared with attribute warning: Hello World [-Wattribute-warning]
```

Тут є цікавий технічний нюанс, на який я натрапив під час перевірки. Цей атрибут спрацьовує, **тільки якщо виклик `f()` доживає до пізніх стадій компіляції**. На `-O0` усе гаразд, попередження є. А на `-O2` компілятор інлайнить порожню `f()` і викидає виклик ще до того, як атрибут встигне спрацювати, тому попередження **зникає**. Тобто наявність Hello World залежить від рівня оптимізації.

**#87. `__attribute__((error(...)))`**

```cpp
__attribute__((error("Hello World")))
void f();

int main() { f(); }
```

```text
error: call to 'f' declared with attribute error: Hello World
```

Аналогічно до `warning`, але якщо виклик доживає до кодогенерації, то компіляція падає з нашим повідомленням.
На відміну від #86, я тут залишив `f()` **без тіла**, бо без LTO невизначену функцію неможливо заінлайнити, тому виклик гарантовано доживає, і помилка спрацьовує на будь-якому рівні оптимізації.

**#88. `__attribute__((unavailable("…")))`**

```cpp
__attribute__((unavailable("Hello World")))
void f();

int main() { f(); }
```

```text
error: 'void f()' is unavailable: Hello World
```

`unavailable` спрацьовує на **рівні семантичного аналізу**, тобто на будь-яке _використання_ імені, тому **не залежить від оптимізації**.

**#89. `__attribute__((diagnose_if(…)))` - лише Clang**

```cpp
__attribute__((diagnose_if(1, "Hello World", "warning")))
void f() {}

int main() { f(); }
```

```text
warning: Hello World [-Wuser-defined-warnings]
```

Clang дозволяє повісити на функцію **умовну** діагностику з власним текстом. GCC просто ігнорує атрибут (`warning: 'diagnose_if' attribute directive ignored`).

### Асемблерні директиви

**#90. `asm(".error …")`**

```cpp
asm(".error \"Hello World\"");
int main() {}
```

```text
Error: Hello World
```

Рядок друкує вже не компілятор, а GNU `as`, коли натрапляє на директиву `.error`.
Clang з інтегрованим асемблером має аналогічну поведінку: `error: Hello World`.

**#91. `asm(".warning …")`**

```cpp
asm(".warning \"Hello World\"");
int main() {}
```

```text
Warning: Hello World
```

Те саме, але рівень warning: об'єктний файл усе одно збереться, асемблер лише попередить.

**#92. `asm(".print …")`**

```cpp
asm(".print \"Hello World\"");
int main() {}
```

```text
Hello World
```

Асемблер, на відміну від решти цієї секції, друкує рядок у **stdout**, а не у stderr.

> **Підсумок compile-time: 16 способів.**

---

## Фінал: усі дороги ведуть до `write(2)`

**Загальний підсумок: 92 способи** надрукувати "Hello World\n" у консоль у C++ на Linux.
З них 53 - стандартний C++.

| Категорія                         | Кількість |
| --------------------------------- | --------: |
| Стандартний C++26 (рантайм)       |        46 |
| POSIX (+ glibc unlocked)          |        18 |
| Розширення (BSD/glibc)            |         6 |
| Суто Linux                        |         6 |
| Compile-time (стандартний C++)    |         7 |
| Compile-time (нестандартні)       |         9 |
| **Всього**                        |    **92** |

Врешті, майже всі рантайм методи зводяться до одного системного виклику `write(2)`. І лише чотири мають власний системний виклик: `writev`, `sendfile`, `splice` та `io_uring`.

![Майже усі дороги ведуть до write()](images/hello-world-funnel.svg#center)

### Скільки буферів між тобою і ядром

Окрема тема, навколо якої багато плутанини: скільки буферів стоїть між викликом і ядром:

| Спосіб                                                                                                                           | Буферизація                                                                | Коли реально йде `write(2)`                                                |
| -------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------- | -------------------------------------------------------------------------- |
| `write`, `writev`, `dprintf`, `syscall`, asm, `/dev/tty`                                                                         | немає                                                                      | одразу, на кожен виклик                                                    |
| C stdio: `printf`, `fprintf`, `puts`, `fputs`, `fwrite`, `putchar`, `putc`, `fputc`, `print`, `println` (і `_unlocked`-двійники) | буфер `stdout` (`FILE*`)                                                   | у термінал - на кожен `\n`; у файл/pipe - коли буфер повний або при виході |
| iostream: `cout <<`, `.write`, `.put`, `sputn`, `sputc`, STL-ітератори                                                           | у дефолті - той самий буфер `stdout`; з `sync_with_stdio(false)` - власний | так само, плюс явний `flush` / `endl`                                      |

Тобто прямі способи пишуть у ядро одразу, буферизовані флашаться або на `\n` (у термінал), або коли буфер заповниться, або під час нормального виходу з програми (`exit` флашить всі stdio-буфери й викликає деструктори статичних `cout`).

Ще хочеться розказати про нюанс з `cerr` і `clog` (#24 і #25). Прийнято вважати, що cerr небуферизований, а clog буферизований.

`std::cerr` має виставлений прапор `unitbuf`, тому він флашиться після **кожної** операції виводу. `std::clog` цього прапора не має. Здавалося б, `clog` мав би накопичувати output, але по дефолту (`sync_with_stdio(true)`) обидва потоки пишуть у C-шний `stderr`, а він **сам по собі небуферизований**. Тому на POSIX платформах насправді обидва пишуть одразу. Я перевірив через `strace` (рядок `"Hello" << " " << "World" << "\n"` - це 4 операції):

```text
strace -e write ./cerr   ->   4 separate write(2, …)
strace -e write ./clog   ->   4 separate write(2, …)
```

Різниця з'являється, тільки якщо від'єднати iostream від stdio:

```cpp
std::ios_base::sync_with_stdio(false);
std::clog << "Hello" << " " << "World" << "\n";   // now 1 write(2, "Hello World\n", 12)
std::cerr << "Hello" << " " << "World" << "\n";    // still 4 - unitbuf flushes every time
```

Ось тепер `clog` справді складає все в буфер і флашить одним `write` наприкінці, а `cerr` через `unitbuf` усе одно флашить на кожній операції.

Врешті, якщо запустити способи, що базуються на write, то `strace -e write` всюди покаже однаковий результат з точністю до дескриптора:

```text
strace -e write ./cout     ->  write(1, "Hello World\n", 12)
strace -e write ./printf   ->  write(1, "Hello World\n", 12)
strace -e write ./write    ->  write(1, "Hello World\n", 12)
strace -e write ./syscall  ->  write(1, "Hello World\n", 12)
strace -e write ./cerr     ->  write(2, "Hello World\n", 12)
```

Навіть непійманий `throw` (#41) врешті просто пише в stderr: (`write(2, "terminate called…", 48)`, далі `write(2, "Hello World", 11)`).

Отакі справи, малята. Тому я не розумію людей, які кажуть, що C++ роздутий. Все дуже просто і лаконічно.

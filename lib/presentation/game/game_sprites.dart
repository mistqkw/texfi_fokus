import '../../domain/entities/game_rules.dart';

/// Пиксельные существа игрового слоя.
///
/// Требование к этому файлу — не техническое, а художественное: каждый
/// дрифер и особенно каждый босс должен читаться как отдельное существо, а
/// не как тот же спрайт в другом цвете. Поэтому у всех разный силуэт,
/// разные пропорции и разный «характер» деталей — крылья, ноги, глаза,
/// рамка. Перекрасить один силуэт было бы вдвое быстрее и вдесятеро хуже:
/// на карте из двенадцати узлов повтор виден мгновенно.
///
/// Сетки крупнее иконочных 8×8 — 12×12 для дриферов и 16×16 для боссов:
/// на восьми клетках силуэт схлопывается в пятно, и все существа
/// становятся одинаковыми поневоле.
abstract final class GameSprites {
  // --- Обычные дриферы, 12×12 ---

  /// Гудок: почти всё существо — размах крыльев, тело мелкое, сверху усики.
  /// Горизонтальный, широкий, «налетающий» — то самое «звякнуло и утащило».
  static const List<String> drifterBuzz = [
    '...x....x...',
    '...ox..xo...',
    '....x..x....',
    '.xo.xxxx.ox.',
    'oxxxxooxxxxo',
    'xxxo.xx.oxxx',
    '.xxxxxxxxxx.',
    '..xoxxxxox..',
    '...x.oo.x...',
    '..x..xx..x..',
    '...o....o...',
    '............',
  ];

  /// Ползун: длинная низкая лента на множестве коротких ног, прижатая к
  /// нижнему краю кадра. Не налетает сверху, а подбирается снизу — и место
  /// в кадре занимает ровно противоположное крылатому: тот висит в центре
  /// и вверху, этот стелется по земле.
  static const List<String> drifterCreep = [
    '............',
    '............',
    '............',
    '..oo....oo..',
    '.oxxo..oxxo.',
    '.x........x.',
    'xxxxxxxxxxxx',
    'xoxoxxoxoxox',
    'xxxxxxxxxxxx',
    'x..x..x..x..',
    '.x..x..x..x.',
    'o..o..o..o..',
  ];

  /// Морок: высокий, узкий, с одним большим пустым глазом и рваным подолом.
  /// Вертикаль против горизонталей первых двух; ничего не делает — просто
  /// стоит и смотрит, и в этом вся его помеха.
  static const List<String> drifterLoom = [
    '.....xx.....',
    '....xxxx....',
    '...xxxxxx...',
    '..xxxxxxxx..',
    '..xxoooxxx..',
    '..xo...oxx..',
    '..xo...oxx..',
    '..xxoooxxx..',
    '..xxxxxxxx..',
    '..xxoxxoxx..',
    '..x.xx.x.x..',
    '..x..x...x..',
  ];

  // --- Мир 2: те же 12×12, но ни одного знакомого силуэта ---

  /// Клубок: две воронки, сходящиеся в тонкой перемычке посередине. Ничего
  /// сплошного — только скрещённые нити, и чем ближе к центру, тем туже.
  static const List<String> drifterTangle = [
    '............',
    '.xx......xx.',
    '.oxx....xxo.',
    '..oxx..xxo..',
    '...oxxxxo...',
    '....oxxo....',
    '....oxxo....',
    '...oxxxxo...',
    '..oxx..xxo..',
    '.oxx....xxo.',
    '.xx......xx.',
    '............',
  ];

  /// Мошкара: единственный «дрифер», у которого нет тела. Восемь мелких
  /// пятен по краям кадра и пустота в середине — взгляду не за что
  /// зацепиться, и в этом вся суть.
  static const List<String> drifterMote = [
    'xx......xx..',
    'xo......ox..',
    '...ox.......',
    '...xx.......',
    'xx........xx',
    'xo........ox',
    '..xo....ox..',
    '..xx....xx..',
    'xx......xx..',
    'xo......ox..',
    '....xx.ox...',
    '....xo.xx...',
  ];

  /// Скорлупа: замкнутое кольцо и ничего внутри. Самый лёгкий силуэт на
  /// карте — одна линия по кругу.
  static const List<String> drifterHusk = [
    '....xxxx....',
    '..xxoooxx...',
    '.xo......ox.',
    '.x........x.',
    'xo........ox',
    'x..........x',
    'x..........x',
    'xo........ox',
    '.x........x.',
    '.xo......ox.',
    '..xxoooxx...',
    '....xxxx....',
  ];

  // --- Мир 3 ---

  /// Воронка: тяжёлая сплошная шапка во всю ширину, сходящаяся к тонкой
  /// ножке. Вертикаль, но перевёрнутая относительно Морока — тот тяжёл
  /// внизу, эта сверху.
  static const List<String> drifterSiphon = [
    'xxxxxxxxxxxx',
    'xoooooooooox',
    '.xxoooooxxx.',
    '..xxoooxxx..',
    '...xxoxxx...',
    '....xxxx....',
    '....xoox....',
    '.....xx.....',
    '.....ox.....',
    '.....xo.....',
    '....xxxx....',
    '....oooo....',
  ];

  /// Узел: столб во всю высоту с двумя перекладинами поперёк. Единственная
  /// фигура на карте, построенная из прямых углов, — она не существо, она
  /// препятствие.
  static const List<String> drifterKnot = [
    '.....xx.....',
    '.....xx.....',
    'xxxxxooxxxxx',
    'xoooxxxxooox',
    '.....xx.....',
    '.....xx.....',
    '..xxxxxxxx..',
    '..xoo..oox..',
    '.....xx.....',
    '.....xx.....',
    '.....xx.....',
    '....o..o....',
  ];

  /// Полог: косая масса из угла в угол с обтрёпанным нижним краем.
  /// Единственный несимметричный силуэт — он один «падает» в сторону.
  static const List<String> drifterVeil = [
    'xxxxxxx.....',
    'xxxxxxxx....',
    'oxxxxxxxx...',
    '.oxxxxxxxx..',
    '..oxxxxxxxx.',
    '...oxxxxxxxx',
    '....oxxxxxxx',
    '....o.oxxxxx',
    '...o...ooxx.',
    '..o.....o...',
    '.o..........',
    'o...........',
  ];

  static List<String> drifter(DrifterSpecies species) => switch (species) {
        DrifterSpecies.buzz => drifterBuzz,
        DrifterSpecies.creep => drifterCreep,
        DrifterSpecies.loom => drifterLoom,
        DrifterSpecies.tangle => drifterTangle,
        DrifterSpecies.mote => drifterMote,
        DrifterSpecies.husk => drifterHusk,
        DrifterSpecies.siphon => drifterSiphon,
        DrifterSpecies.knot => drifterKnot,
        DrifterSpecies.veil => drifterVeil,
        DrifterSpecies.echo => drifterEcho,
        DrifterSpecies.ledger => drifterLedger,
        DrifterSpecies.pendulum => drifterPendulum,
        DrifterSpecies.mirror => drifterMirror,
        DrifterSpecies.bloom => drifterBloom,
        DrifterSpecies.thorn => drifterThorn,
        DrifterSpecies.ember => drifterEmber,
        DrifterSpecies.weight => drifterWeight,
        DrifterSpecies.door => drifterDoor,
      };

  // --- Мир 4: всё возвращается ---

  /// Эхо: фигура и её выцветающая копия со сдвигом. Одно и то же,
  /// сказанное ещё раз — и слышно, что это уже было.
  static const List<String> drifterEcho = [
    'xxxx........',
    'xxxxxx......',
    'xx..xx......',
    'xx..xx..oo..',
    'xxxxxx.oooo.',
    'xxxxxx.oo.oo',
    'xxxxxx.oooo.',
    'xx..xx..oo..',
    'xx..xx......',
    'xxxxxx......',
    'xxxx........',
    '............',
  ];

  /// Список: стопка одинаковых строк во весь кадр, снизу нарастает
  /// новая. Вычеркнутое не кончает список, а освобождает в нём место.
  static const List<String> drifterLedger = [
    'xxxxxxxxxxxx',
    'xoooooooooox',
    'xxxxxxxxxxxx',
    'xoooooooooox',
    'xxxxxxxxxxxx',
    'xoooooooooox',
    'xxxxxxxxxxxx',
    'xoooooooooox',
    'xxxxxxxxxxxx',
    '.oxxxxxxxxo.',
    '..oxxxxxxo..',
    '...oooooo...',
  ];

  /// Маятник: подвес, груз и дуга полутоном по обе стороны. Уходит и
  /// возвращается ровно туда же — движение без перемещения.
  static const List<String> drifterPendulum = [
    '....xxxx....',
    '....xoox....',
    '.....xx.....',
    '.....xx.....',
    'o....xx....o',
    'oo...xx...oo',
    '.o...xx...o.',
    '.o..xxxx..o.',
    '..o.xxxx.o..',
    '..oxxxxxxo..',
    '...oxxxxo...',
    '....oooo....',
  ];

  // --- Мир 5: всё красивое ---

  /// Зеркало: рама во весь кадр, внутри — смутный силуэт, в котором
  /// узнаётся сам персонаж. Единственный дрифер, который ничего не
  /// делает сам.
  static const List<String> drifterMirror = [
    'xxxxxxxxxxxx',
    'xo........ox',
    'x..oooooo..x',
    'x..o.oo.o..x',
    'x..ooooooo.x',
    'x..o.oooo..x',
    'x...oooo...x',
    'x...o..o...x',
    'x..o....o..x',
    'xo........ox',
    'xxxxxxxxxxxx',
    '..x......x..',
  ];

  /// Цвет: раскрытые лепестки вокруг тёмной сердцевины. Симметричный и
  /// приятный — тем и берёт.
  static const List<String> drifterBloom = [
    '....o..o....',
    '...oxxxxo...',
    '..oxx..xxo..',
    '.ox..xx..xo.',
    'ox..xxxx..xo',
    'o..xxxxxx..o',
    'o..xxxxxx..o',
    'ox..xxxx..xo',
    '.ox..xx..xo.',
    '..oxx..xxo..',
    '...oxxxxo...',
    '.....xx.....',
  ];

  /// Шип: мелкий, кривой, наискось в углу кадра. Единственный, кто не
  /// занимает центр: по отдельности пустяк, цепляет каждый раз.
  static const List<String> drifterThorn = [
    '..........x.',
    '.........xx.',
    '........xxo.',
    '.......xxo..',
    '......xxo...',
    '.....xxo....',
    '..o.xxo.....',
    '.oxxxo......',
    'oxxxo.......',
    'xxxo........',
    'oxo.........',
    'o...........',
  ];

  // --- Мир 6: остаётся только своё ---

  /// Уголёк: ядро и зола кольцом. Не помеха снаружи, а то, что осталось
  /// от собственного внимания к концу дня.
  static const List<String> drifterEmber = [
    '............',
    '....oooo....',
    '..oo.xx.oo..',
    '..o.xxxx.o..',
    '.o.xxxxxx.o.',
    '.o.xxooxx.o.',
    '.o.xxooxx.o.',
    '.o.xxxxxx.o.',
    '..o.xxxx.o..',
    '..oo.xx.oo..',
    '....oooo....',
    '............',
  ];

  /// Груз: низкий тяжёлый блок, вдавленный в нижний край. Самый
  /// плотный силуэт в наборе — у него нет ни просветов, ни отростков.
  static const List<String> drifterWeight = [
    '............',
    '............',
    '....xxxx....',
    '...xxxxxx...',
    '..xxxxxxxx..',
    '.xxoooooxxx.',
    'xxxoooooxxxx',
    'xxxxxxxxxxxx',
    'xxxoooooxxxx',
    'xxxxxxxxxxxx',
    'ooxxxxxxxxoo',
    'oo........oo',
  ];

  /// Дверь: проём, за которым такая же комната. Рама в раме в раме.
  static const List<String> drifterDoor = [
    'xxxxxxxxxxxx',
    'xoooooooooox',
    'xo.xxxxxx.ox',
    'xo.xoooox.ox',
    'xo.xo..ox.ox',
    'xo.xo..ox.ox',
    'xo.xo..ox.ox',
    'xo.xo.xox.ox',
    'xo.xoooox.ox',
    'xo.xxxxxx.ox',
    'xoooooooooox',
    'xxxxxxxxxxxx',
  ];

  // --- Боссы, 16×16. У каждого мира свой, со своей идеей ---

  /// Мир 1 — Лента. Свернувшаяся кольцами бесконечная лента: спираль,
  /// которая уходит внутрь себя и не кончается. Округлый замкнутый силуэт
  /// с двумя опорами внизу — бесконечная прокрутка, вставшая на ноги.
  static const List<String> bossScroll = [
    '................',
    '..xxxxxxxxxxxx..',
    '.xoooooooooooox.',
    '.xo..........ox.',
    '.xo.xxxxxxxx.ox.',
    '.xo.xoooooxx.ox.',
    '.xo.xo.xx.ox.ox.',
    '.xo.xo.xo.ox.ox.',
    '.xo.xo.xx.ox.ox.',
    '.xo.xooooooo.ox.',
    '.xo.xxxxxxxx.ox.',
    '.xo..........ox.',
    '.xoooooooooooox.',
    '..xxxxxxxxxxxx..',
    '....xx....xx....',
    '...oxx....xxo...',
  ];

  /// Мир 2 — Хор. Не одно существо, а гроздь: множество мелких голов с
  /// собственными глазами на общем основании. Верхний край нарочно
  /// бугристый, силуэт распадается на части — рой, который говорит разом.
  static const List<String> bossChorus = [
    '..xx..xx..xx....',
    '.xoox.xoox.xox..',
    '.xxxxxxxxxxxxx..',
    '.x.xx.x.xx.x.x..',
    '.xoxxoxoxxoxox..',
    '..xx..xx..xx..x.',
    '.xxxxxxxxxxxxxx.',
    '.x.xx.x.xx.x.xx.',
    '.xoxxoxoxxoxoxx.',
    '..xxxxxxxxxxxx..',
    '...xoxxxxxxox...',
    '...x.xxxxxx.x...',
    '...xoxxxxxxox...',
    '....x.x..x.x....',
    '...xx.x..x.xx...',
    '...oo.o..o.oo...',
  ];

  /// Мир 3 — Пустота. Самый простой и самый тяжёлый силуэт: массивная
  /// сплошная рама во весь кадр, а внутри — ничего, к центру сходятся
  /// клинья. Единственный босс, у которого «тело» — это отсутствие тела.
  static const List<String> bossHollow = [
    'xxxxxxxxxxxxxxxx',
    'xoooooooooooooox',
    'xo............ox',
    'xo.x........x.ox',
    'xo.xx......xx.ox',
    'xo..xx....xx..ox',
    'xo...xx..xx...ox',
    'xo....xxxx....ox',
    'xo....xxxx....ox',
    'xo...xx..xx...ox',
    'xo..xx....xx..ox',
    'xo.xx......xx.ox',
    'xo.x........x.ox',
    'xo............ox',
    'xoooooooooooooox',
    'xxxxxxxxxxxxxxxx',
  ];

  /// Мир 4 — Карусель. Кольцо из одинаковых фигур на общей оси: день,
  /// который приходит снова. Единственный босс с осевой симметрией —
  /// у него нет ни начала, ни конца, только оборот.
  static const List<String> bossCarousel = [
    '.......xx.......',
    '......xxxx......',
    '..xxxxxxxxxxxx..',
    '.xoooooooooooox.',
    'xx.xx.xxxx.xx.xx',
    'xo.xo.xoox.ox.ox',
    'xx.xx.xxxx.xx.xx',
    'xoooooooooooooox',
    'xx.xx.xxxx.xx.xx',
    'xo.xo.xoox.ox.ox',
    'xx.xx.xxxx.xx.xx',
    '.xoooooooooooox.',
    '..xxxxxxxxxxxx..',
    '....x......x....',
    '...xx......xx...',
    '..oo........oo..',
  ];

  /// Мир 5 — Отражение. Две половины одного силуэта: левая заливкой,
  /// правая — её полутоновый двойник. Босс, у которого нет своей формы,
  /// он берёт её у того, кто пришёл.
  static const List<String> bossReflection = [
    '.....xxxxxx.....',
    '...xxxxxxoooo...',
    '..xxxxxxxoooooo.',
    '.xxx.xxxxoo.ooo.',
    '.xx...xxxoo...oo',
    'xxx.x.xxxoo.o.oo',
    'xxx...xxxoo...oo',
    'xxxxxxxxxoooooo.',
    'xxxxxxxxxoooooo.',
    'xxx...xxxoo...oo',
    'xxx.x.xxxoo.o.oo',
    '.xx...xxxoo...oo',
    '.xxx.xxxxoo.ooo.',
    '..xxxxxxxoooooo.',
    '...xxxxxxoooo...',
    '.....xxxxxx.....',
  ];

  /// Мир 6 — Последний. Почти пустой кадр, углы рамки и в центре то, с
  /// чего всё начиналось: та же фигура, что у первой ступени аватара,
  /// только выросшая. Самый тихий силуэт из всех — и самый поздний.
  static const List<String> bossLast = [
    'xxx..........xxx',
    'xxo..........oxx',
    'x..............x',
    '.....xxxxxx.....',
    '....xxxxxxxx....',
    '...xxxxooxxxx...',
    '...xxxo..oxxx...',
    '..xxxo....oxxx..',
    '..xxxo....oxxx..',
    '...xxxo..oxxx...',
    '...xxxxooxxxx...',
    '....xxxxxxxx....',
    '.....xxxxxx.....',
    'x..............x',
    'xxo..........oxx',
    'xxx..........xxx',
  ];

  /// Босс мира. За пределами реализованных миров silently не падаем —
  /// выдаём последнего.
  static List<String> boss(int world) => switch (world) {
        1 => bossScroll,
        2 => bossChorus,
        3 => bossHollow,
        4 => bossCarousel,
        5 => bossReflection,
        _ => bossLast,
      };

  // --- Аватар персонажа, 12×12 ---
  //
  // Не человек и не зверь: огонёк. Шесть ступеней, а не деталь на каждый
  // уровень — иначе изменение перестаёт читаться как событие.
  //
  // Полутон здесь работает по смыслу, а не для красоты: у пламени горячая
  // середина и остывающий край, и второй тон — единственный способ это
  // показать, не разрезая силуэт дырами. Заодно он даёт росту вторую ось:
  // огонёк не просто становится больше, у него разгорается ядро.

  /// Ступень 0 (уровни 1–2) — искра. Всё, что есть, — ядро.
  static const List<String> avatarSpark = [
    '............',
    '............',
    '.....oo.....',
    '....oxxo....',
    '...oxxxxo...',
    '...oxxxxo...',
    '....oxxo....',
    '.....oo.....',
    '............',
    '............',
    '............',
    '............',
  ];

  /// Ступень 1 (3–5) — огонёк обрёл форму и полую сердцевину.
  static const List<String> avatarFlame = [
    '............',
    '.....xx.....',
    '....xxxx....',
    '...xxoxxx...',
    '...xo..ox...',
    '..xxo..oxx..',
    '..xxxooxxx..',
    '...xxxxxx...',
    '....oxxo....',
    '.....oo.....',
    '............',
    '............',
  ];

  /// Ступень 2 (6–9) — вокруг огонька зажигаются искры по углам.
  static const List<String> avatarAura = [
    'o....xx....o',
    '.o..xxxx..o.',
    '...xxoxxx...',
    '..xxo..oxx..',
    '..xo....ox..',
    '.xxo....oxx.',
    '.xxxxooxxxx.',
    '..xxxxxxxx..',
    '...oxxxxo...',
    '.o..oxxo..o.',
    'o....oo....o',
    '............',
  ];

  /// Ступень 3 (10+) — сверху смыкается корона, снизу расходятся лучи.
  static const List<String> avatarCrown = [
    'x.x.oxxo.x.x',
    '.xxxxxxxxxx.',
    'x.xxoxxoxx.x',
    '...xxxxxx...',
    '..xxo..oxx..',
    '.xxo....oxx.',
    '.xo......ox.',
    '.xxxxooxxxx.',
    '..xxxxxxxx..',
    '...oxxxxo...',
    '.o..oxxo..o.',
    'x...o..o...x',
  ];

  /// Ступень 4 (15–20) — корона смыкается в сплошной венец, лучи идут
  /// по всем четырём сторонам.
  static const List<String> avatarCorona = [
    'x.oxxxxxxo.x',
    '.xxxxxxxxxx.',
    'xxxxoxxoxxxx',
    '.xxxxxxxxxx.',
    '..xxo..oxx..',
    '.xxo....oxx.',
    '.xo......ox.',
    '.xxxxooxxxx.',
    '.xxxxxxxxxx.',
    '..xxxxxxxx..',
    '.x.oxxxxo.x.',
    'x.x.oxxo.x.x',
  ];

  /// Ступень 5 (21+) — огонёк занимает почти весь кадр: сердцевина всё ещё
  /// полая, но вокруг неё уже не аура, а сплошное свечение.
  static const List<String> avatarSun = [
    'x.oxxxxxxo.x',
    'xxxxxxxxxxxx',
    'xxxoxxxxoxxx',
    'xxxxxxxxxxxx',
    '.xxxo..oxxx.',
    '.xxo....oxx.',
    '.xxo....oxx.',
    '.xxxxooxxxx.',
    'xxxxxxxxxxxx',
    'xxxoxxxxoxxx',
    '.xxxxxxxxxx.',
    'x.x.oxxo.x.x',
  ];

  /// Все ступени аватара по порядку — от искры к почти-солнцу.
  ///
  /// Список, а не только функция: экран персонажа показывает по нему всю
  /// лестницу впереди, и держать её порядок в двух местах было бы верным
  /// способом однажды разойтись.
  static const List<List<String>> avatarStages = [
    avatarSpark,
    avatarFlame,
    avatarAura,
    avatarCrown,
    avatarCorona,
    avatarSun,
  ];

  static List<String> avatar(int stage) =>
      avatarStages[stage.clamp(0, avatarStages.length - 1)];

  // --- Мелочи интерфейса карты ---

  /// Череп — узел пройден.
  static const List<String> nodeCleared = [
    '..xxxx..',
    '.xxxxxx.',
    'xx.xx.xx',
    'xxxxxxxx',
    'xx.xx.xx',
    '.xxxxxx.',
    '..x..x..',
    '..xxxx..',
  ];

  /// Замок — узел ещё закрыт.
  static const List<String> nodeLocked = [
    '..xxxx..',
    '.x....x.',
    '.x....x.',
    'xxxxxxxx',
    'xxx..xxx',
    'xxx..xxx',
    'xxxxxxxx',
    '........',
  ];

  /// Меч — здесь идёт бой.
  static const List<String> nodeCurrent = [
    '......xx',
    '.....xxx',
    '....xxx.',
    'x..xxx..',
    '.xxxx...',
    '..xx....',
    '.xx.x...',
    'xx...x..',
  ];
}

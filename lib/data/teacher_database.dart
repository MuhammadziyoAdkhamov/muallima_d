import '../models/teacher_models.dart';

const List<TeacherExercise> initialTeacherExercises = [
  TeacherExercise(
    id: 'ex_fotima',
    studentName: 'Fotima',
    studentAvatar: '🧕',
    topic: 'Mubtado va xabar moslashuvi',
    arabicText: 'الطَّالِبَةُ مُجْتَهِدٌ فِي الدَّرْسِ',
    errors: [
      TeacherErrorItem(
        wrong: 'مُجْتَهِدٌ',
        correct: 'مُجْتَهِدَةٌ',
        options: ['مُجْتَهِدَةٌ', 'مُجْتَهِدُونَ', 'مُجْتَهِدَانِ'],
        reason:
            'Mubtado ayol jinsidagi birlikda kelgan, shuning uchun xabar ham ayol jinsida bo‘lishi kerak.',
      ),
    ],
    rewardCoins: 50,
  ),
  TeacherExercise(
    id: 'ex_umar',
    studentName: 'Umar',
    studentAvatar: '👳‍♂️',
    topic: 'Olmosh va hozirgi zamon fe’li',
    arabicText: 'أَنَا يَكْتُبُ الدَّرْسَ',
    errors: [
      TeacherErrorItem(
        wrong: 'يَكْتُبُ',
        correct: 'أَكْتُبُ',
        options: ['أَكْتُبُ', 'تَكْتُبُ', 'نَكْتُبُ'],
        reason:
            'أَنَا — birinchi shaxs birlik olmoshi. U bilan fe’l أَكْتُبُ shaklida keladi.',
      ),
    ],
    rewardCoins: 50,
  ),
  TeacherExercise(
    id: 'ex_maryam',
    studentName: 'Maryam',
    studentAvatar: '🌸',
    topic: 'Qaratqich birikmasi (idofa)',
    arabicText: 'قَلَمُ الطَّالِبُ جَدِيدٌ',
    errors: [
      TeacherErrorItem(
        wrong: 'الطَّالِبُ',
        correct: 'الطَّالِبِ',
        options: ['الطَّالِبِ', 'الطَّالِبَ', 'الطَّالِبٌ'],
        reason:
            'Idofada mudof ilayh doimo majrur bo‘ladi, shuning uchun oxiri kasra bilan keladi.',
      ),
    ],
    rewardCoins: 50,
  ),
  TeacherExercise(
    id: 'ex_ali',
    studentName: 'Ali',
    studentAvatar: '👦',
    topic: 'Ikkilikdagi fe’l moslashuvi',
    arabicText: 'الطَّالِبَانِ يَذْهَبُونَ إِلَى الْمَدْرَسَةِ',
    errors: [
      TeacherErrorItem(
        wrong: 'يَذْهَبُونَ',
        correct: 'يَذْهَبَانِ',
        options: ['يَذْهَبَانِ', 'يَذْهَبُ', 'يَذْهَبُونَ'],
        reason:
            'الطَّالِبَانِ ikkilikda kelgan, shuning uchun fe’l ham ikkilik shaklida bo‘lishi kerak.',
      ),
    ],
    rewardCoins: 50,
  ),
  TeacherExercise(
    id: 'ex_zaynab',
    studentName: 'Zaynab',
    studentAvatar: '🌷',
    topic: 'Ko‘rsatish olmoshlari',
    arabicText: 'هَذَا بِنْتٌ مُجْتَهِدَةٌ',
    errors: [
      TeacherErrorItem(
        wrong: 'هَذَا',
        correct: 'هَذِهِ',
        options: ['هَذِهِ', 'هَذَا', 'هَؤُلَاءِ'],
        reason:
            'بِنْتٌ ayol jinsidagi birlik ot, unga هَذِهِ ko‘rsatish olmoshi mos keladi.',
      ),
    ],
    rewardCoins: 50,
  ),
];

const List<GiftItem> initialGiftsList = [
  GiftItem(
    id: 'gift_shokolad',
    giftName: 'Shokolad',
    priceCoins: 100,
    icon: '🍫',
    description: 'Sevimli shirinlik (Dilnavoz uchun maxsus)',
  ),
  GiftItem(
    id: 'gift_kofe',
    giftName: 'Sevimli qahvaxonada kofe',
    priceCoins: 250,
    icon: '☕',
    description: 'Eng shinam qahvaxonada kofe date',
  ),
  GiftItem(
    id: 'gift_kitob',
    giftName: 'Kitob do‘konidan yangi kitob',
    priceCoins: 500,
    icon: '📚',
    description: 'Siz yoqtirgan mavzudagi ajoyib yangi kitob',
  ),
  GiftItem(
    id: 'gift_gullar',
    giftName: 'Gul dastasi',
    priceCoins: 750,
    icon: '💐',
    description: 'Muallimaga loyiq eng nafis gullar guldastasi',
  ),
  GiftItem(
    id: 'gift_kino',
    giftName: 'Kino yoki teatr chiptasi',
    priceCoins: 1000,
    icon: '🎬',
    description: 'Birgalikda romantik va qiziqarli kino/teatr oqshomi',
  ),
];

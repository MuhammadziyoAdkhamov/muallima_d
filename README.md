# Arab tili — shaxsiy o‘quv ilovasi

Flutter asosidagi arab tili mikro-ta’lim ilovasi. O‘quvchi profili, kunlik dars, takrorlash va natijalar hozircha bitta qurilmada ishlaydi.

## Hozirgi imkoniyatlar

- Pastel rangli bosh sahifa, streak, haftalik odat kalendari, kunlik reja va o‘quv yo‘li.
- Yorug‘ va qorong‘i rejim.
- O‘quvchi ismi va mavzu bo‘yicha o‘tilgan so‘zlar qurilmada saqlanadi.
- So‘z kartochkalari: ma’no, transliteratsiya va arabcha o‘zak.
- Kuniga 6 tagacha yangi yoki muddati kelgan so‘zdan tuziladigan dars.
- Xatoga iliq javob, dars yakuni va to‘g‘ri javoblar uchun XP.
- XP, o‘rganilgan so‘zlar, streak, xatolar va o‘qilgan daqiqalar qurilmada saqlanadi.
- Xato qilingan so‘zlar ertangi takrorlash ro‘yxatiga qo‘shiladi; takrorlash alohida dars bo‘lib, XP yoki streakni takroran bermaydi.
- Qiyin so‘zlar daftari rejalashtirilgan va bugun takrorlashga tayyor so‘zlarni ko‘rsatadi.
- So‘zlar va yutuqlar sahifalari, jumladan haftalik o‘qish hisoboti.

O‘quv kontenti hozircha ilovaga kiritilgan demo lug‘at, profil va o‘quv natijalari esa `shared_preferences` orqali shu qurilmada saqlanadi. Firebase sinxronizatsiyasi, AI asosidagi tahlil va admin panel hali ulanmagan; demak, turli qurilmalar o‘rtasida ma’lumot almashmaydi.

## Ishga tushirish

```shell
flutter pub get
flutter run
```

Web brauzerda sinash uchun:

```shell
flutter run -d chrome
```

## Asosiy fayllar

- `lib/main.dart` — ilovani ishga tushirish va lokal saqlashni ulash.
- `lib/app.dart` — tema va asosiy sahifalar navigatsiyasi.
- `lib/data/local_learning_store.dart` — qurilmadagi profil va o‘quv natijalari.
- `lib/data/word_database.dart` — lug‘at va dars savollarini tuzish.
- `test/widget_test.dart` — profil, tema, kunlik dars va takrorlash oqimi testlari.
- `web/manifest.json` — Flutter web ilova manifesti.

Keyingi bosqichda lokal ma’lumotlar uchun sinxronizatsiya, kontent boshqaruvi va AI asosidagi adaptiv tavsiyalar alohida ishlab chiqilishi kerak. Hozirgi versiya bu imkoniyatlarni taqdim etmaydi.

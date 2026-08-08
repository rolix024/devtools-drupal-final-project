# מילון מושגי כלי פיתוח - Drupal

פרויקט מסכם בקורס כלי פיתוח: אתר Drupal בעברית, מבוסס Docker ו-MySQL, עם ערכת נושא RTL, תוכן התחלתי, גיבוי, שחזור וניקוי אוטומטיים.

## חברי הצוות

- ירין לודר
- ליה ג'וני

## מה נדרש ומה בוצע

- רשת Docker פנימית משותפת בשם `devtools-drupal-network`.
- קונטיינר MySQL רשמי ועדכני, חשיפת פורט `3306` וסיסמת root כנדרש: `my-secret-pw`.
- קונטיינר Drupal רשמי ועדכני, חשיפת האתר בפורט `8080`.
- התקנת Drupal אוטומטית וחיבור ל-MySQL בשם השירות `database`.
- חשבון מנהל `demoadmin` עם הסיסמה `secretpass`.
- ממשק ותוכן בעברית וערכת נושא מותאמת ל-RTL.
- האלמנט הראשי של כל דף נוצר כ-`<html dir="rtl" lang="he">` דרך `html.html.twig`.
- 43 ערכים ממילון המושגים הרשמי ב-Moodle; ניתן לערוך ולהוסיף תכנים דרך Drupal.
- Volumes מתמשכים למסד הנתונים ולקבצי Drupal.
- סקריפטים מלאים להקמה, גיבוי, שחזור וניקוי.

## טכנולוגיות

Docker, Docker Compose, Drupal, PHP, Twig, CSS, MySQL, Bash ו-Git.

## מדריך מלא - משכפול ועד הפעלה

1. שכפלו את המאגר ועברו לתיקייה:

   ```bash
   git clone <repository-address>
   cd <repository-folder>
   ```

2. העניקו הרשאת הרצה לסקריפטים:

   ```bash
   chmod +x setup.sh backup.sh restore.sh cleanup.sh
   ```

3. הריצו את ההקמה:

   ```bash
   ./setup.sh
   ```

   בהרצה הראשונה נוצר `.env` מתוך `.env.example`, הכולל את שם האתר ואת חשבונות חברי הצוות.

4. פתחו [http://localhost:8080](http://localhost:8080). כניסת המנהל היא:

   - שם משתמש: `demoadmin`
   - סיסמה: `secretpass`

   חשבונות חברי הצוות:

   - `Yarin` / `Yarin1`
   - `Liya` / `Liya1`

5. הוספת משתמש: היכנסו אל `יצירה > הוספת משתמש`. מומלץ לא לתת הרשאת מנהל למשתמשים רגילים.

6. הוספת מושג: היכנסו אל `יצירה > מושג במילון`, כתבו כותרת והסבר בעברית ופרסמו.

## בדיקות שימושיות

```bash
docker compose ps
docker compose logs -f drupal
curl -I http://localhost:8080
```

כדי לוודא RTL בדף בפועל:

```bash
curl -s http://localhost:8080 | grep -m1 '<html'
```

הפלט צריך לכלול `dir="rtl"` ו-`lang="he"`.

## גיבוי

כאשר האתר פועל:

```bash
./backup.sh
```

הסקריפט יוצר בתיקיית `backups` שני קבצים מתוארכים:

- `drupal-db-*.sql.gz` - גיבוי MySQL בעזרת `mysqldump`.
- `drupal-files-*.tar.gz` - קבצי `sites`, `modules` ו-`themes` מתוך ה-Volumes.

קובצי הגיבוי הסופיים מצורפים למאגר.

## שחזור במכונה אחרת

1. שכפלו את המאגר והעתיקו את שני קבצי הגיבוי לתיקיית `backups`.
2. הריצו שחזור אוטומטי מהגיבויים החדשים ביותר:

   ```bash
   ./restore.sh
   ```

3. לחלופין, ציינו קבצים מפורשות:

   ```bash
   ./restore.sh backups/drupal-db-YYYYMMDD-HHMMSS.sql.gz backups/drupal-files-YYYYMMDD-HHMMSS.tar.gz
   ```

4. פתחו את האתר ובדקו תוכן, משתמשים ועיצוב.

## ניקוי מלא

ודאו תחילה שקיים גיבוי תקין, ואז הריצו:

```bash
./cleanup.sh
```

לאחר אישור, הסקריפט מוחק את קונטיינרי הפרויקט, הרשת, ה-Image המקומי וכל ה-Volumes. קבצי הגיבוי המקומיים נשמרים כדי לאפשר שחזור.

## מבנה הפרויקט

```text
compose.yaml                 תיאור שירותי MySQL ו-Drupal
docker/drupal/Dockerfile     Image מותאם עם Drush
docker/drupal/entrypoint.sh  התקנת אתר אוטומטית
web/themes/custom/           ערכת הנושא העברית וה-RTL
web/modules/custom/          מודול תוכן המילון הראשוני
setup.sh                     הקמה
backup.sh                    גיבוי
restore.sh                   שחזור
cleanup.sh                   ניקוי
```

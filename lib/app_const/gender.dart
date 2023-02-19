/// This file is saving the const of the changing in the languages between
/// the different genders
/// Example: save the Hebrew's male and female address language

const maleToFemaleMap = {
  "אתה בטוח": "את בטוחה",
  "אתה יכול": "את יכולה",
  "דרג ": "דרגי ",
  "אתה ": "את ",
  "בטוח ": "בטוחה ",
  "בטוח?": "בטוחה?",
  "הפעל": "הפעלי",
  "צור ": "צרי ",
  "בחר ": "בחרי ",
  "סמן ": "סמני ",
  "הכנס ": "הכניסי ",
  "הוסף ": "הוסיפי ",
  "הזמן ": "הזמיני ",
  "שתרצה": "שתרצי",
  "בטל ": "בטלי ",
  "לחץ ": "לחצי ",
  "הזן ": "הזיני ",
  "הקלד ": "הקלדי ",
  "שבהן את עובד": "שבהן את עובדת",
  "כאן תוכל להוסיף": "כאן תוכלי להוסיף",
  "במסך זה תוכל": "במסך זה תוכלי",
  "עדיין מתלבט": "עדיין מתלבטת",
  "ותוכל": "ותוכלי",
  "סיים": "סיימי",
  "המשך": "המשיכי",
  "ברוך הבא": "ברוכה הבאה",
  "נסה ": "נסי ",
  "תהיה ": "תהיי ",
  "התקשר": "התקשרי",
  "תוסר": "תוסרי",
  "הזמיני שהיומן": "הזמן שהיומן",
  "באפשרותך לסמני": "באפשרותך לסמן",
  "ממליצים לסמני": "ממליצים לסמן",
  "המשיכי חייב": "המשך חייב"
};

enum Gender { male, female, anonymous }

const Map<Gender, String> genderToStr = {
  Gender.male: "male",
  Gender.female: "female",
  Gender.anonymous: "anonymous",
};

const Map<String, Gender> genderFromStr = {
  "male": Gender.male,
  "female": Gender.female,
  "anonymous": Gender.anonymous,
};

/// Thes file is saving the const vars of the "fonts" options
/// example: the supported fonts for each language

enum Languages {
  all,
  english,
  hebrew,
  bengali,
  chineseHongKong,
  chineseSimplified,
  chineseTraditional,
}

const displayLang = <Languages, String>{
  Languages.all: 'All',
  Languages.english: "English", // not in fontsByLang -> helper return
  Languages.hebrew: "Hebrew",
  Languages.bengali: "Bengali",
  Languages.chineseHongKong: "Chinese (Hong Kong)",
  Languages.chineseSimplified: "Chinese (Simplified)",
  Languages.chineseTraditional: "Chinese (Traditional)",
};

const fontsByLang = <Languages, Set<String>>{
  Languages.chineseTraditional: {
    'Noto Sans Traditional Chinese',
    'Noto Serif Traditional Chinese',
  },
  Languages.chineseHongKong: {
    'Noto Sans Hong Kong',
    'Noto Serif Hong Kong',
  },
  Languages.chineseSimplified: {
    'Noto Sans Simplified Chinese',
    'Noto Serif Simplified Chinese',
    'ZCOOL XiaoWei',
    'ZCOOL QingKe HuangYou',
    'Ma Shan Zheng',
    'ZCOOL KuaiLe',
    'Zhi Mang Xing',
    'Long Cang',
    'Lui Jian Mao Cao'
  },
  Languages.bengali: {
    'Hind Siliguri',
    'Noto Serif Bengali',
    'Baloo Da 2',
    'Noto Sans Bengali',
    'Galada',
    'Atma',
    'Mina',
    'Tiro Bangla',
    'Anek Bangla'
  },
  Languages.hebrew: {
    'Open Sans',
    'Rubic',
    'Heebo',
    'Arimo',
    'Varela round',
    'M PLUS Rounded 1c',
    'Assistant',
    'Secular One',
    'Amatic SC',
    'M PLUS 1p',
    'Tinos',
    'Frank Ruhl Libre',
    'Solitreo',
    'Alef',
    'Cousine',
    'Rubic Vinyl',
    'Rubic 80s Fade',
    'Rubic Spray Paint',
    'Rubic Gemstones',
    'Rubic Storm',
    'David Libre',
    'Miriam Libre',
    'Suez One',
    'Bellefair',
    'Rubic Moonrocks',
    'Noto Sans Hebrew',
    'Fredoka',
    'Rubic Dirt',
    'Rubic Distressed',
    'Rubic Marker Hatch',
    'Rubic Burned',
    'Rubic Iso',
    'Rubic Maze',
    'Karantina',
    'Bona Nova',
    'Rubic Bubbles',
    'Rubic Glitch',
    'Rubic Puddles',
    'Rubic Wet Paint',
    'Rubic Microbe',
    'IBM Plex Sans Hebrew',
    'Rubic Beastly',
    'Noto Serif Hebrew',
    'Noto Rashi Hebrew',
  }
};

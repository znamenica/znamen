#!/bin/bash
set -x

#color set
#d5c3ad
#..
#d8c9b0
#dbccb7
#e1d1bf
#e5d7c4
#..
#e8dcce
#
#
#
#20180b
#...
#1a1209
#150f07
#0e0a04
#060503
#...
#000000

#fb3321 - 202120
#fc301f - 202120

name="Богослужебный круг"
#declare -x djvus pdfs
book=book
mkdir -p "$book"

chapter[1]="Вечерня"
chapter[15]="Павечерница"
chapter[18]="Полунощница"
chapter[21]="Утреня"
chapter[51]="Тайная"
chapter[101]="Месячник"
chapter[201]="Требник"

section[1]="Псалом предначинательный"
section[2]="Псалом рядовой"
section[3]="Воззвахи"
section[4]="Догматики"
section[5]="Свете тихий"
section[6]="Прокимны"

section[15]="С нами Бог"

section[21]="Псалмы предначинательные"
section[22]="Тропари начальные"
section[23]="Шестопсалмие"
section[24]="Бог Господь"
section[25]="Аллилуия"
section[26]="Кафизмы рядовые"
section[27]="Седальны кафизмы"
section[28]="Полиелей"
section[29]="17-я кафизма"
section[30]="Ангельский собор"
section[31]="Ипакои"
section[32]="Седальны полиелейные"
section[33]="Степенны"
section[34]="Прокимны"
section[35]="Евангелие"
section[36]="Молитвами"
section[37]="Сходницы"
section[38]="Песнь Богородицы"
section[39]="Хвалитны"
section[40]="Евангельские стихиры"
section[41]="Великое славословие"

section[51]="Литургийные строки"
section[51]="Антифоны"
section[53]="Единородный сыне"
section[54]="Блаженны"
section[51]="Прокимны, аллилуарий и проч"
section[56]="Херувимская песнь"
section[51]="Начало тайни верных"
section[58]="Символ веры"
section[59]="Евхаристический канон"
section[60]="Достойно есть"
section[61]="Задостойники"
section[51]="Подостойники"
section[63]="Запричастники"
section[64]="Попричастники с аллилуею"
section[65]="Стихира кресту"

section[101]="Рождество Богородицы"
section[102]="Крестовоздвижение"
section[103]="Введение во храм"
section[104]="Зачатие Анны"
section[105]="Рождество Христово"
section[106]="Богоявление"
section[107]="Сретение"
section[108]="Триодь постная"
section[109]="Мытаря и фарисея"
section[110]="Блудная неделя"
section[111]="Сырная неделя"
section[112]="Прощеное воскресенье"
section[113]="Торжество православия"
section[114]="Григорьев день"
section[115]="Крестопоклонная неделя"
section[116]="Лествичников день"
section[117]="Мариино стояние"
section[118]="Суббота акафиста"
section[119]="Мариин день"
section[120]="Благовещение"
section[121]="Лазорева суббота"
section[122]="Цветная неделя"
section[123]="Великий четверток"
section[124]="Великий пяток"
section[125]="Великая суббота"
section[126]="Пасха"
section[127]="Фомина неделя"
section[128]="Жен мироносиц неделя"
section[129]="Расслабленная неделя"
section[130]="Преполовение"
section[131]="Самарянская неделя"
section[132]="Слепая неделя"
section[133]="Вознесение"
section[134]="Никейского собора неделя"
section[135]="Великая родительская суббота"
section[136]="Пятидесятница"
section[137]="Духов день"
section[138]="Всехсвятская неделя"
section[139]="Петропавлов день"
section[140]="Владимиров день"
section[141]="Изнесение древа креста"
section[142]="Преображение"
section[143]="Успение"
section[144]="Усекновение главы"

section[201]="Последование по усопшим"

function pre {
    QW=70%
    QR=60%

    f=$(sed "s/.png$//" <<< "$1")
    convert -channel a -white-threshold $QW "$f.png" "$f.1.ppm"
    convert -channel r -threshold $QR "$f.1.ppm" "$f.2.ppm"
    convert -channel gb -threshold 99% "$f.2.ppm" "$f.3.ppm"
    convert -noise 1 "$f.3.ppm" "$f.gif"
    rm -f "$f*.ppm"
}

function book {
    dir=$2
    f=$(sed -e "s/.xcf$//" -e "s/.*\///" <<< "$1")

    [ ! -f "$2/$f.djvu" -o ! -f "$2/$f.pdf" ] || return

    convert -background rgb\(220,209,191\) -flatten "$1" "$2/$f.ppm"
    if [ ! -f "$2/$f.djvu" ]; then
	cpaldjvu -dpi 150 -colors 4 "$2/$f.ppm" "$2/$f.djvu"
    fi

    if [ ! -f "$2/$f.pdf" ]; then
	gm convert "$2/$f.ppm" "$2/$f.pdf"
#	gm convert "$2/$f.ppm" -resize 1381x1754 "$2/$f.pdf" #also 150 dpi
    fi
    rm -f "$2/$f.ppm"
}

c=''
i=0
for j in `seq 1 100`
do
    if [ ${chapter[$j]} ]; then
	c=${chapter[$j]}
	i=$[$i+1]
    fi
    s=${section[$j]}
    k=1
    for f in "$j"/*png
    do
	ii=0
#	pre "$f"
    done
    for f in "$j"/*xcf
    do
	nf=$(printf "%s/%i.%.2i. %s - %s. %.3i.xcf" "$j" $i $j "$c" "$s" $k)
	[ "$f" = "$nf" ] || mv "$f" "$nf"
	book "$nf" "$book"
	k=$[$k+1]
    done
done

djvm -c "$name.djvu" "$book"/*.djvu
pdftk "$book"/*.pdf cat output "$name.pdf"


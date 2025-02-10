
from multiprocessing import Pool
 
def wordcount(text) :
    arr = text.upper().split(" ")
    wc = {}
    for word in arr :
        if word in wc.keys() :
            wc[word] = wc[word]+1
        else :
            wc[word] = 1
    return wc

 
# protect the entry point
if __name__ == '__main__':
    wc = {}
    
    str1 = "The quick brown fox jumped over the lazy dog."
    str2 = "Sally sells sea shells by the sea shore."
    str3 = "How much wood would a woodchuck chuck if a woodchuck could chuck wood?"
    str4 = "Roberta ran rings around the Roman ruins"
    str5 = "The sixth sick sheik's sixth sheep's sick"
    str6 = "Four furious friends fought for the phone"
    str7 = "Fuzzy Wuzzy was a bear. Fuzzy Wuzzy had no hair. Fuzzy Wuzzy wasn't very fuzzy, was he?"
    str8 = "Which witch switched the Swiss wristwatches"
    str9 = "I scream, you scream, we all scream for ice cream"
    str10 = "Peter Piper picked a peck of pickled peppers"
    str11 = "A big black bug bit a big black bear."
    str12 = "Betty Botter bought some butter, but she said the butter's bitter. If I put it in my batter, it will make my batter bitter."
    str13 = "How many cans can a canner can if a canner can can cans? A canner can can as many cans as a canner can, if a canner can can cans."
    str14 = "I thought a thought, but the thought I thought wasn't the thought I thought I thought."
    str15 = "If practice makes perfect and perfect needs practice, I’m perfectly practiced and practically perfect."


    # create the Pool
    pool = Pool()

    results = pool.map(wordcount, [str1, str2, str3, str4, str5, str6, str7, str8, str9, str10, str11, str12, str13, str14, str15])    

    for result in results :
        for key in result.keys() : 
            if key in wc.keys() :
                wc[key] = wc[key] + result[key]
            else :
                wc[key] = result[key]

    print(wc)
    
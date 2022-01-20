import re


test_str = "p.delta*X(3)*P_Cart*P_Cat"
matches = re.finditer(r"(P_[a-zA-Z]+)", test_str, re.MULTILINE | re.UNICODE)

for matchNum, match in enumerate(matches, start=1):
    #print ("Match {matchNum} was found at {start}-{end}: {match}".format(matchNum = matchNum, start = match.start(), end = match.end(), match = match.group()))
    print(match.group())
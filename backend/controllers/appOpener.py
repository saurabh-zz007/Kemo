from AppOpener import open , close

def openApp(appName):
    if(open(appName)):
        return True
    else:
        return False

def closeApp(appName):
    if(close(appName, match_closest=True)):
        return True
    else:
        return False

ACTIONS = {
    "openApp": openApp,
    "closeApp": closeApp,
}
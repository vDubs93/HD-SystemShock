import os

with open("GLDEFS.sprites", 'w') as gldefs:
    for file in os.listdir("./"):
        if len(file.split(".")) == 1 or file.split(".")[1] == "png":
            gldefs.write("HardwareShader Sprite {}".format(file.split(".")[0]) +
                         "\n{\n\tShader shaders/ColorCycle\n\tSpeed 1\n" +
                         '\tTexture pal1 "shaders/cycle1.bmp"\n' +
                         '\tTexture pal2 "shaders/cycle2.png"\n' +
                         '\tTexture pal3 "shaders/cycle3.png"\n' +
                         '\tTexture pal4 "shaders/cycle4.png"\n' +
                         '\tTexture pal5 "shaders/cycle5.png"\n' +
                         '\tTexture pal6 "shaders/cycle6.png"\n' +
                         "}\n\n")

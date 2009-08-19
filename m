From: Ivo Calado <ivocalado@embedded.ufcg.edu.br>
Date: Wed, 19 Aug 2009 11:22:10 +0000
Subject: Weird behavior in "ioctl (so, FIONREAD, &readsize)" system call
Message-Id: <cb00fa210908190422h79916b4avd179d6d24f125870@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello guys,
    I developed a client/server application using DCCP sockets.The
client of my application connects to the server which in turn creates
a ClientSocketHandle  to perform I/O. The operations of reading and
writing were performed correctly.

Although, I'm with a problem to retrieve the number of bytes available
for reading using the function ioctl (so, FIONREAD, &readsize).

When the client calls the function iotcl, the value assigned to
readsize is the number corresponding to the bytes sent by the server,
as expected. However, when the client of server perform the same
operation to find the number of bytes sent by the client the value
assigned to readsize pointer is 0 (zero) even when there are data in
this socket that could be read. So, why the value of readsize in the
server side is still 0?

Best regards,


Ivo




--
Ivo Augusto Andrade Rocha Calado
MSc. Candidate
Embedded Systems and Pervasive Computing Lab - http://embedded.ufcg.edu.br
Systems and Computing Department - http://www.dsc.ufcg.edu.br
Electrical Engineering and Informatics Center - http://www.ceei.ufcg.edu.br
Federal University of Campina Grande - http://www.ufcg.edu.br

PGP: 0x03422935
Quidquid latine dictum sit, altum viditur.

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 20 Aug 2009 18:36:32 +0000
Subject: Re: Weird behavior in "ioctl (so, FIONREAD, &readsize)" system call
Message-Id: <20090820183631.GA5348@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <cb00fa210908190422h79916b4avd179d6d24f125870@mail.gmail.com>
In-Reply-To: <cb00fa210908190422h79916b4avd179d6d24f125870@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| When the client calls the function iotcl, the value assigned to
| readsize is the number corresponding to the bytes sent by the server,
| as expected. However, when the client of server perform the same
| operation to find the number of bytes sent by the client the value
| assigned to readsize pointer is 0 (zero) even when there are data in
| this socket that could be read. So, why the value of readsize in the
| server side is still 0?
Sorry I have difficulties understanding above sentence, as it refers
to the client twice.

Arnaldo has designed FIONREAD (SIOCINQ) as in UDP, so the behaviour
is as in the udp(7) manpage, i.e. 
 * if there is a datagram in the socket receive buffer, return its size;
 * if there is no datagram in the socket receive buffer, return 0.

From this, it seems that your application does not have a datagram
ready when the readsize at the server is 0, i.e. there is no data
in the socket?

(I think gstreamer has an example of using this ioctl, maybe that helps.)

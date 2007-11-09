From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 09 Nov 2007 13:51:27 +0000
Subject: Re: How much is available for reading on the socket?
Message-Id: <20071109135127.GA21951@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
In-Reply-To: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > using "ioctl (socket, FIONREAD, &readsize)" I can get how much is
| > available to read from the socket using TCP. Is there a equivalent
| > option for DCCP?
| 
| Looks like dccp_ioctl() happily returns -ENOIOCTLCMD (for now). If you
| have IO and memory to waste, you can always recv(..., MSG_PEEK) to work
| around this.
| 
Arnaldo wrote a patch which realises SIOCINQ (it is in 2.6.24-rc1/2).

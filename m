From: <burakgmail-dccp@yahoo.com>
Date: Fri, 18 Aug 2006 13:15:53 +0000
Subject: Re: [BUG] CCID3 - loss not detected if in order
Message-Id: <20060818131553.95576.qmail@web30007.mail.mud.yahoo.com>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
In-Reply-To: <5640c7e00607201930k6650084oc75a868a6011a525@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ian, 
 
I had been trying to get a "p" value other than zero from some days, and I was relieved when I read your post yesterday. 
 
So I applied your lossfix and ccid3li patches (and all the other patches in http://wand.net.nz/~iam4/dccp/patches/ actually) to my linux boxes (both sender&receiver) and started some testing. However, the linux box at the receiver side (scenario: sending data from sender to receiver) got freezed everytime I played the scenario and I had to switch off/on the machine to get it back to life. There seems to be a problem related with the patches I applied, maybe txbuff patch. Do you have any idea? 
 
Burak Gorkemli
Ph.D. Candidate
Koc University
Turkey
 



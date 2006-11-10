From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 10 Nov 2006 15:16:32 +0000
Subject: Re: RFC about 07a_putative_nested_lock_in_rcv.diff
Message-Id: <200611101516.32639@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611100550w7343a3d5l45cc0e4bc4703d0d@mail.gmail.com>
In-Reply-To: <39e6f6c70611100550w7343a3d5l45cc0e4bc4703d0d@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > |  but can't we just use bh_lock_sock_nested in sk_receive_skb?
|  > I am not sure about that one - I don't know all the functions calling
|  > sk_receive_skb (cscope says ppoe.c / dn_nsp_in.c use this too).
|  >
|  > In the TCP/DCCP case it is clear (due to the cloning while one is held under
|  > a lock), but for other contexts it might be different and cause subtle problems.
|  
|  Yup, that is why I asked, I'll investigate this further later to see
|  if its safe for the !INET cases.
There had been an earlier attempt to do this in sk_clone, but it was abandoned
since it lead to problems:
  http://www.mail-archive.com/dccp@vger.kernel.org/msg00356.html

- Gerrit

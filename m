From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Apr 2016 18:26:42 +0000
Subject: Re: How to get creatior PID information for the local tcp connection
Message-Id: <1460053602.6473.415.camel@edumazet-glaptop3.roam.corp.google.com>
List-Id: <dccp.vger.kernel.org>
References: <CADCeU4NfNucPCqemSxr4SsMUgdOhxzM41zjsRDKfrhsFyMH0+Q@mail.gmail.com>
In-Reply-To: <CADCeU4NfNucPCqemSxr4SsMUgdOhxzM41zjsRDKfrhsFyMH0+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, 2016-04-07 at 23:01 +0530, Vishnu Pratap Singh wrote:
> Hi,
> 
> 
> Issue -  How to get PID information for the local tcp connection
> 
> 
> 
> i want to get the creator PID for each socket in user space for local
> tcp connection, i see in kernel there is support for returing PID with
> "SO_PEERCRED" ioctl to work across namespaces. it uses struct pid and
> struct cred to store the peer credentials on struct sock.
> cred_to_ucred(sk->sk_peer_pid, sk->sk_peer_cred, &peercred); Above
> function stores the PID information in ucred->pid = pid_vnr(pid); and
> same is returned via "SO_PEERCRED" ioctl .
> 
> But for local tcp connection i get pid as 0, is there any way i can
> get the PID information. Any help or suggestion will be highly
> helpful.
> 
> 

man 7 socket

       SO_PEERCRED
              Return the credentials of the foreign  process  connected  to  this  socket.
              This  is  possible  only  for  connected  AF_UNIX stream sockets and AF_UNIX
              stream and datagram socket pairs created using socketpair(2);  see  unix(7).
              The  returned  credentials  are those that were in effect at the time of the
              call to connect(2) or socketpair(2).  The argument  is  a  ucred  structure;
              define  the  GNU_SOURCE  feature test macro to obtain the definition of that
              structure from <sys/socket.h>.  This socket option is read-only.



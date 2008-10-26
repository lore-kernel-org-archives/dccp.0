From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Sun, 26 Oct 2008 21:33:54 +0000
Subject: [PATCH 1/1] [QPOLICY]: Ignore packets with specific priority
Message-Id: <200810262233.54649.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="Boundary-00=_CJOBJO0L8e9xZx+"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

--Boundary-00=_CJOBJO0L8e9xZx+
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch allows certain packets to be discarded based on its priority. This
allows for creation of userspace queuing policies.

This patch is not meant for inclusion in test tree, it is only to provide base 
for discussion. Last time (quite a few months ago) when we discussed how 
qpolicies should be implemented we couldn't reach a conclusion how parameters 
should be detected, not even if they should be detected at runtime at all. 
This trivial patch allows qpolicies to be moved to userspace as demonstrated 
by attached C# code (requires mono). This way userspace-kernelspace interface 
is dead simple allowing for quite a lot flexibility in designing the way 
packet buffer is organized.

The basic idea is that we set send buffer size so that only one packet fits in 
it. Sending second packet while first is inside buffer (has not been sent 
yet) causes send() to block until ccid allows the first packet to be 'send'. 
For each real packet we call send() twice: one 'fake' (will be discarded just 
before sending) and one 'real' (contains user data). This makes all the 
waiting to be done on the 'fake' packet making sending the real one really 
fast. This allows for late data choice without difficult to implement ring 
buffers shared by user and kernel space or complicated qpolicies code on 
kernel side.

Results on CCID2 are very promising (near ideal), but CCID3 is somewhat 
disappointing to the extent I'm starting to think that I'm doing something 
seriously wrong while testing it.

Therefore I have two questions:
1. What do you think about the idea in general?
2. Could anybody test the attached code on both CCID2 and CCID3 and send 
results/observations to the list?

(Don't ask why packets with priority 65 are discarded. It's just a random 
number.)
---
 net/dccp/qpolicy.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/dccp/qpolicy.c b/net/dccp/qpolicy.c
index 27383f8..e639523 100644
--- a/net/dccp/qpolicy.c
+++ b/net/dccp/qpolicy.c
@@ -43,6 +43,8 @@ static struct sk_buff *qpolicy_prio_best_skb(struct sock 
*sk)
 	skb_queue_walk(&sk->sk_write_queue, skb)
 		if (best == NULL || skb->priority > best->priority)
 			best = skb;
+	if (best == NULL || best->priority == 65)
+		return NULL;
 	return best;
 }
 
@@ -120,11 +122,11 @@ struct sk_buff *dccp_qpolicy_pop(struct sock *sk)
 {
 	struct sk_buff *skb = dccp_qpolicy_top(sk);
 
-	/* Clear any skb fields that we used internally */
-	skb->priority = 0;
-
-	if (skb)
+	if (skb) {
+		/* Clear any skb fields that we used internally */
+		skb->priority = 0;
 		skb_unlink(skb, &sk->sk_write_queue);
+	}
 	return skb;
 }
 
-- 
1.5.4.5


--Boundary-00=_CJOBJO0L8e9xZx+
Content-Type: text/x-c++src;
  charset="utf-8";
  name="DccpClient.cs"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="DccpClient.cs"

using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Runtime.InteropServices;
using DccpLib;

namespace Test
{
	public class Testapp
	{
		public static void Main(string[] args)
		{
			if(args.Length!=3)
			{
				Console.WriteLine("3 argument required");
				return;
			}
			using(DccpSocket socket = new DccpSocket(args[0], args[1], new PriorityQP(int.Parse(args[2]))))
			{
				DateTime expected = DateTime.Now;
				int waitTime = 20;
				for(int i=0;i<4000;i++)
				{
					string tosend=""+i%4+"000qwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuiopqwertyuio_"+i.ToString("D4");;
					socket.Enqueue(Encoding.UTF8.GetBytes(tosend), i%4);
					Thread.Sleep(waitTime);
					expected = expected.AddMilliseconds(20);
					waitTime = Math.Max(0, 20 - (int)(DateTime.Now - expected).TotalMilliseconds);
				}
			}
		}
	}
}

--Boundary-00=_CJOBJO0L8e9xZx+
Content-Type: text/x-csrc;
  charset="utf-8";
  name="libdccp.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="libdccp.c"

#include "dccp.h"
#include <netdb.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <sys/time.h>
#include <stdio.h>

int dccp_send(int sockfd, char* buffer, int bufsize, int priority)
{
	struct msghdr msg;
	struct iovec iov[1];
	iov[0].iov_base=buffer;
	iov[0].iov_len=bufsize;
	msg.msg_iov=iov;
	msg.msg_iovlen=1;
	msg.msg_name=NULL;
	msg.msg_namelen=0;

	struct cmsghdr	*cmsg;
	uint8_t	cmsg_area[CMSG_SPACE(sizeof(__u32))];

	/* Fill ins information required by CMSG_FIRSTHDR() */
	msg.msg_control    = cmsg_area;
	msg.msg_controllen = sizeof cmsg_area;

	cmsg = CMSG_FIRSTHDR(&msg);
	cmsg->cmsg_level = SOL_DCCP;
	cmsg->cmsg_type	 = DCCP_SCM_PRIORITY;
	cmsg->cmsg_len	 = CMSG_LEN(sizeof(__u32));

	/* update the total length value */
	msg.msg_controllen = cmsg->cmsg_len;

	__u32 *prio = (__u32*)CMSG_DATA(cmsg);
	*prio=priority;
	errno=0;
	return sendmsg(sockfd, &msg, 0);
}

int dccp_connect(int sockfd, char* address, char* port)
{
	struct addrinfo *hostinfo;
	getaddrinfo(address, port, NULL, &hostinfo);
	return connect(sockfd, hostinfo->ai_addr, hostinfo->ai_addrlen);
}

--Boundary-00=_CJOBJO0L8e9xZx+
Content-Type: text/x-c++src;
  charset="utf-8";
  name="DccpLib.cs"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="DccpLib.cs"

using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using System.Runtime.InteropServices;

namespace DccpLib
{
	public class DccpSocket : IDisposable
	{
		const int SOL_DCCP = 269;
		const int DCCP_SOCKOPT_QPOLICY_TXQLEN = 17;
		const int DCCP_SOCKOPT_QPOLICY_ID = 16;
		const int SOL_SOCKET = 1;
		const int SO_SNDBUF = 7;
		const int AF_INET = 2;
		const int SOCK_DCCP = 6;
		const int IPPROTO_DCCP = 33;
		
		[DllImport("libdccp.so")]
		public extern static int dccp_send(int sockfd, byte[] buffer, int bufsize, int priority);
		[DllImport("libdccp.so", CharSet = CharSet.Ansi)]
		public extern static int dccp_connect(int sockfd, string address, string port);

		[DllImport("libc.so.6")]
		public extern static int setsockopt(int sockfd, int level, int option_name, byte[] option_value, int option_len);
		[DllImport("libc.so.6")]
		public extern static int close(int sockfd);
		[DllImport("libc.so.6")]
		public extern static int socket(int socket_family, int socket_type, int protocol);

		int sockfd;
		Thread sender;
		AutoResetEvent are;
		byte[] maxpacket = new byte[16376];
		IQueuePolicy qpolicy;
		
		public DccpSocket(string address, string port, IQueuePolicy qp)
		{
			if(qp == null)
				throw new ArgumentNullException("qp");
			qpolicy = qp;
			are = new AutoResetEvent(false);
			sockfd = socket(AF_INET, SOCK_DCCP, IPPROTO_DCCP);
			if(sockfd < 0)
				throw new Exception("Cannot create DCCP socket.");
			int result;

			byte[] bufsize = BitConverter.GetBytes(maxpacket.Length);
		    result=setsockopt(sockfd, SOL_SOCKET, SO_SNDBUF, bufsize, bufsize.Length);
			if(result < 0)
				throw new Exception("Setsockopt (SO_SNDBUF) call failed.");

			byte[] policy_txqlen = BitConverter.GetBytes(2);
		    result=setsockopt(sockfd, SOL_DCCP, DCCP_SOCKOPT_QPOLICY_TXQLEN, policy_txqlen, policy_txqlen.Length);
			if(result < 0)
				throw new Exception("Setsockopt (DCCP_SOCKOPT_QPOLICY_TXQLEN) call failed.");

			byte[] policy_id = BitConverter.GetBytes(1);
		    result=setsockopt(sockfd, SOL_DCCP, DCCP_SOCKOPT_QPOLICY_ID, policy_id, policy_id.Length);
			if(result < 0)
				throw new Exception("Setsockopt (DCCP_SOCKOPT_QPOLICY_ID) call failed.");

			result=dccp_connect(sockfd, address, port);
			if(result < 0)
				throw new Exception("Connect call failed.");
			
			sender = new Thread(new ThreadStart(sendPackets));
			sender.Start();
		}

		public void Dispose()
		{
			Close();
		}
		
		public void Close()
		{
			sender.Abort();
			close(sockfd);
		}
		
		public void Enqueue(byte[] buffer, object priority)
		{
			lock(qpolicy)
			{
				qpolicy.Push(buffer, priority);
				are.Set();
			}
		}
		
		void sendPackets()
		{
			for(bool shouldwait=true;;)
			{
				if(shouldwait)
					are.WaitOne();
				if(dccp_send(sockfd, maxpacket, maxpacket.Length, 65)<0)
					throw new Exception("send failed");
				lock(qpolicy)
				{
					var best = qpolicy.Pop();
					if(best == null)
					{
						shouldwait = true;
						continue;
					}
					if(dccp_send(sockfd, best, best.Length, 66) < 0)
						throw new Exception("send failed");
					shouldwait = false;
				}
			}
		}
	}
	
	public interface IQueuePolicy
	{
		void Push(byte[] buffer, object priority);
		byte[] Pop();
	}
	
	public class PriorityQP : IQueuePolicy
	{
		List<KeyValuePair<int, byte[]>> list = new List<KeyValuePair<int, byte[]>>();
		int maxsize;
		
		public PriorityQP(int queueLength)
		{
			maxsize=queueLength;
		}
		
        public void Push(byte[] buffer, object priority)
		{
			list.Add(new KeyValuePair<int, byte[]>((int)priority, buffer));
			KeyValuePair<int, byte[]> worst=new KeyValuePair<int, byte[]>(255, null);
			foreach(var pair in list)
				if(pair.Key<worst.Key)
					worst=pair;
			if(list.Count>maxsize)
				list.Remove(worst);
		}
		
		public byte[] Pop()
		{
			var best=new KeyValuePair<int, byte[]>(0, null);
			foreach(var pair in list)
				if(pair.Key>=best.Key)
					best=pair;
			list.Remove(best);
			if(best.Value!=null)
				Console.WriteLine("Sending "+best.Key);
			return best.Value;
		}
	}
}

--Boundary-00=_CJOBJO0L8e9xZx+
Content-Type: text/x-makefile;
  charset="utf-8";
  name="Makefile"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="Makefile"

CC = gcc
CFLAGS = -Wall -g
TARGETS = libdccp.so DccpLib.dll DccpClient.exe

all: $(TARGETS)

DccpClient.exe: DccpClient.cs DccpLib.dll
	gmcs -optimize -reference:DccpLib.dll DccpClient.cs

DccpServer.exe: DccpServer.cs DccpLib.dll
	gmcs -optimize -reference:DccpLib.dll DccpServer.cs

DccpLib.dll: DccpLib.cs
	gmcs -optimize -target:library DccpLib.cs

libdccp.so: libdccp.c
	gcc -fPIC -g -c -Wall libdccp.c
	gcc -shared -Wl,-soname,libdccp.so.1 -o libdccp.so libdccp.o -lc

clean:
	rm $(TARGETS) *.o

--Boundary-00=_CJOBJO0L8e9xZx+
Content-Type: text/x-csrc;
  charset="utf-8";
  name="server.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="server.c"

#include "dccp.h"
#include <stdio.h>
#include <time.h>
#include <netdb.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#define SOCK_DCCP 6
#define SOL_DCCP 269
#define IPPROTO_DCCP 33
#include <linux/socket.h>
#include <linux/dccp.h>

int numpackets[256];

void serve(int sockfd)
{
	ssize_t n;
	unsigned char buffer[MAXLINE];
	int i;
again:
	while ((n=read(sockfd, buffer, MAXLINE)) > 0)
	{
		buffer[n]='\0';
		numpackets[buffer[0]]++;
		printf("%d: %s - ", (unsigned int)time(0), buffer);
		for(i=0;i<256;i++)
		{
			if(numpackets[i]>0)
				printf("(%d->%d) ", i, numpackets[i]);
		}
		printf("\n");
		fflush(NULL);
	}

	if (n < 0 && errno == EINTR)
		goto again;
	else if (n < 0)
		printf("read error\n");
}

int main(int argc, char **argv)
{
	int listenfd, connfd;
	struct sockaddr_in servaddr, cliaddr;
	socklen_t clilen;

	if ((listenfd = socket(AF_INET,SOCK_DCCP,IPPROTO_DCCP)) < 0)
	{
		printf("socket error");
		return 1;
	}
	servaddr.sin_family = AF_INET;
	servaddr.sin_addr.s_addr = htonl(INADDR_ANY);
	servaddr.sin_port = htons(APPPORT);

	bind(listenfd, (struct sockaddr *)&servaddr, sizeof(servaddr)); 
	listen(listenfd, 0);
	clilen = sizeof(cliaddr);
	connfd = accept(listenfd,(struct sockaddr *)&cliaddr,&clilen);
	close (listenfd);
	serve(connfd);
	return 0;
}

--Boundary-00=_CJOBJO0L8e9xZx+--

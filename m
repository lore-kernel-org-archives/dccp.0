From: "Leandro Melo de Sales" <leandroal@gmail.com>
Date: Thu, 22 Feb 2007 18:25:25 +0000
Subject: User API and Additional Features
Message-Id: <5bc4c4570702221025yd6903b0n59a2d916c227c4af@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi list,

   I'm currently on the implementation of DCCP Generalized Connection
draft (still studying codes, docs, etc.) as I already talked to
Arnaldo and Eddie, but I already realized that in order to implement
it we will need a more specific user API to permit users to switch
between DCCP connections. Something more than just setsockopt, for
instance. So I ask: is there any affort in define/decide a DCCP
specific API which can externalize dccp specific features to the user?
Another example, from the master tesis of Marie Camier ("Development
of a Adaptative DCCP-Based Voip Client"), is the lack of specific
methods to retrieve connection statistics and other stuffs, such as
connection sequence numbers. Her solution was to retriave these
information directly in the socket, through ioctl() system call.
   Please let me know if I said something *out-of-date*.

Thank you,

[]s
Leandro

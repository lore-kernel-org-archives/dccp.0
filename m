From: "Leandro Sales" <leandroal@gmail.com>
Date: Mon, 29 Sep 2008 18:33:44 +0000
Subject: Protocol not attached
Message-Id: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello folks,
  I'm getting this message while using 2.6.27:

  Can not create DCCP socket (Protocol driver not attached)

  "uname -a" output:
      Linux localhost 2.6.27-rc4-44301-g8269be1 #7 SMP Sun Sep 28 17:02:25
      BRT 2008 i686 AMD Athlon(tm) 64 Processor 3000+ AuthenticAMD GNU/Linux

  Anything wrong? I tried compile DCCP using both static and module
methods and it produces the same effect.

Thank you,
Leandro.

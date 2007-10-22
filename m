From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Mon, 22 Oct 2007 02:00:38 +0000
Subject: How much is available for reading on the socket?
Message-Id: <5bc4c4570710211900o6ccbc9belf2cc904c1b3af0c6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi,
 using "ioctl (socket, FIONREAD, &readsize)" I can get how much is
available to read from the socket using TCP. Is there a equivalent
option for DCCP? I used this with DCCP and I got:

ioctl failed: invalid argument

Leandro.

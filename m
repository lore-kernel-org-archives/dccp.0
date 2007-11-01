From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 01 Nov 2007 22:14:17 +0000
Subject: Re: [PATCH 9/25] Adapt CCID-4 according to the latest changes to
Message-Id: <20071101221417.GB18925@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.35629.leandroal@gmail.com>
In-Reply-To: <200710312130.35629.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Thu, Nov 01, 2007 at 18:44:47 -0300, =C5=81eandro Sales wrote:
> my suggestion is to focus the job on the ccid-4 implementation and
> ccid-3/4 code sharing. After we can quickly solve issues related to
> code style, what do you think?

That's fine with me. No matter how it may seem, I'm really not hunting
for whitespaces.

Talking of CCID 4 implementation, when would it be safe to start porting
changes from old codebase to the new one? I have some Loss Interval and
Dropped Packets -related code available for the old repository, but I
find it somewhat pointless to submit patches when I know the repository
will be written from scratch again, as it was just recently.


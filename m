From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 23 Jan 2006 20:20:54 +0000
Subject: Re: [Fwd: Re: loss detection and tfrc rate]
Message-Id: <39e6f6c70601231220n704dca29v4705a5dd60f9c74e@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <65209.84.56.242.24.1138047195.squirrel@mail2web.iu-bremen.de>
In-Reply-To: <65209.84.56.242.24.1138047195.squirrel@mail2web.iu-bremen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On 1/23/06, h.balan@iu-bremen.de <h.balan@iu-bremen.de> wrote:
>
> It=B4s the net-2.6 version from Dave Miller=B4s git at kernel.org (from a=
 week
> or so ago, quite similar to 2.6.14). If this is not the ultimate source
> for it, I would appreciate a pointer in the right direction.

Right now it is, I haven't anything DCCP related in my net-2.6.17
queue yet, will announce here if I add something there.

That said, the CCID3 code is experimental at best now, doesn't
crashes, "works" in
some very basic scenarios but definetively needs mucho love and care, hope =
your
involvement helps in this area.

- Arnaldo

From: Arnaldo Carvalho de Melo <acme@kernel.org>
Date: Wed, 18 Oct 2017 20:26:55 +0000
Subject: Re: dccp status
Message-Id: <20171018202655.GI3707@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <CAHuN2juQ5Y8HL=MDLDEcNg-4_nbLXYRTBJikViCb0Uuecad+cA@mail.gmail.com>
In-Reply-To: <CAHuN2juQ5Y8HL=MDLDEcNg-4_nbLXYRTBJikViCb0Uuecad+cA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Oct 18, 2017 at 01:08:49PM -0700, Kwame-Lante Wright escreveu:
> Hi everyone,
> 
> I'm trying to get a better sense of the state of DCCP in the Linux
> kernel as I'd like to use it for a project. I found this page
> https://wiki.linuxfoundation.org/networking/todo#DCCP but it seems
> like it might be out of date.
> 
> Any pointers on how to get up to speed on the latest and greatest in
> DCCP development?

Well, its been in basic maintainance mode in the areas it shares with
the other transport protocols, most proeminently TCP, v4 and v6.

IIRC there are patches that need to be evaluated, forward ported, etc,
in Gerrit's tree, I think.

- Arnaldo

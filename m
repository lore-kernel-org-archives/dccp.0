From: "Leandro Sales" <leandroal@gmail.com>
Date: Thu, 06 Nov 2008 13:38:15 +0000
Subject: Re: Protocol not attached
Message-Id: <5bc4c4570811060538h2d662507u5de1fb62c61cd569@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Nov 5, 2008 at 5:27 AM, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Hi Leandro
>
> is there any news regarding the CCID/module loading problem on the 64
> bit computer with 32 bit kernel?
>
> I have tried to compile 32 bit at home, but am currently lacking the
> bits and pieces to do all of it since the installation is mostly 64 bit.
>
> I may try this later.
>
> Gerrit
>
> --
>

Hello Gerrit,
    yes! I think that we found the commit that inserted the problem (probably).

    This is the list of commits, the first time that the problem
occurs is in "f76fd327a8b32d3ad5b51639faf6f54d18be0981". I'm sending
to you the tree commits before the BAD that it is working properly.

 - BAD - Gerrit Renker f76fd327a8b32d3ad5b51639faf6f54d18be0981 dccp
ccid-3: Runtime verification of timer resolution
 - GOOD - Tomasz Grobelny 7d1af6a8d935678248d057564e75e1452409a53c
dccp qpolicy: Parameter checking of cmsg qpolicy parameters
 - GOOD - Tomasz Grobelny d6da3511d6b558d0b017777b61dc08b8fbc06ea4
dccp: Policy-based packet dequeueing infrastructure
 - GOOD - Gerrit Renker ddab05568eaa70fc92b2aae957136f188f724e9c dccp:
Clean up slow-path input processing

Regards,
Leandro.

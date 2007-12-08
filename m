From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sat, 08 Dec 2007 17:16:48 +0000
Subject: Re: [PATCH 3/8] [TFRC/CCID3]: Remove now unused functions /
Message-Id: <20071208171641.GD3180@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <11971083883685-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11971083883685-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Dec 08, 2007 at 10:06:23AM +0000, Gerrit Renker escreveu:
> This removes two things which now have become redundant:
>  1. The function tfrc_rx_hist_entry_delete() is no longer referenced anywhere.
>  2. The CCID3 HC-receiver still inserted timestamps, but received timestamps
>     are not parsed/referenced/used by the HC-sender, it serves no function.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Thanks, applying as two separate patches.

- Arnaldo

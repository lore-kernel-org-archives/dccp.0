From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 11:14:14 +0000
Subject: Re: [PATCH 3/4] CCID4: Signs off patch #2 submitted by Tommi and it organize the copyright and comme
Message-Id: <200709251214.14605@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709201054t564cf7aak2cf4cfcd41623c55@mail.gmail.com>
In-Reply-To: <5bc4c4570709201054t564cf7aak2cf4cfcd41623c55@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I have put the following into the repository and, since in the editor anyway,
done a
	 s/Copyrithg/Copyright/g

Hope that is ok.
  
|  Signed-off-by: Leandro Sales <leandro@embedded.ufcg.edu.br>
|  
|  Please considerer pulling the following as the final patch for the [PATCH 3/4].
|  
|  diff -uprN dccp-ccid4.base/net/dccp/ccids/ccid4.c
|  dccp-ccid4/net/dccp/ccids/ccid4.c
|  --- dccp-ccid4.base/net/dccp/ccids/ccid4.c	2007-09-21 00:05:18.000000000 -0300
|  +++ dccp-ccid4/net/dccp/ccids/ccid4.c	2007-09-21 00:02:56.000000000 -0300
|  @@ -1,15 +1,26 @@
|   /*
|    *  net/dccp/ccids/ccid4.c
|    *
|  + *  Copyright (c) 2007   Federal University of Campina Grande, Paraiba, BR.
|    *  Copyright (c) 2007   University of Helsinki, Finland.
|    *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
|    *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
|  - *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
|    *
|    *  An implementation of the DCCP protocol
|    *
|  + *  Copyrithg (c) 2007 Leandro Sales, Tommi Saviranta
|  + *
|  + *  This code has been developed by the Federal University of Campina Grande
|  + *  Embedded Systems and Pervasive Computing Lab and the Department of Computer
|  + *  Science at the University of Helsinki. For further information please see
|  + *  http://embedded.ufcg.edu.br/ <leandro@embedded.ufcg.edu.br>
|  + *  http://www.cs.helsinki.fi/ <wnd@iki.fi>
|  + *
|  + *  Copyrithg (c) 2005-7 Ian McDonald
|  + *
|    *  This code is based on code developed by the University of Waikato WAND
|    *  research group. For further information please see http://www.wand.net.nz/
|  + *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
|    *
|    *  This code also uses code from Lulea University, rereleased as GPL by its
|    *  authors:
|  @@ -35,6 +46,7 @@
|    *  along with this program; if not, write to the Free Software
|    *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
|    */
|  +
|   #include "../dccp.h"
|   #include "ccid4.h"
|  
|  @@ -1000,7 +1012,8 @@ static __exit void ccid4_module_exit(voi
|   }
|   module_exit(ccid4_module_exit);
|  
|  -MODULE_AUTHOR("Tommi Saviranta <wnd@iki.fi>, "
|  +MODULE_AUTHOR("Leandro Melo de Sales <leandro@embedded.ufcg.edu.br, "
|  +              "Tommi Saviranta <wnd@iki.fi>, "
|   	      "Ian McDonald <ian.mcdonald@jandi.co.nz>, "
|   	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
|   MODULE_DESCRIPTION("DCCP TFRC CCID4 CCID");
|  diff -uprN dccp-ccid4.base/net/dccp/ccids/ccid4.h
|  dccp-ccid4/net/dccp/ccids/ccid4.h
|  --- dccp-ccid4.base/net/dccp/ccids/ccid4.h	2007-09-21 00:05:18.000000000 -0300
|  +++ dccp-ccid4/net/dccp/ccids/ccid4.h	2007-09-21 00:02:56.000000000 -0300
|  @@ -3,12 +3,23 @@
|   /*
|    *  net/dccp/ccids/ccid4.h
|    *
|  + *  Copyright (c) 2007   Federal University of Campina Grande, Paraiba, BR.
|    *  Copyright (c) 2007   University of Helsinki, Finland.
|    *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
|    *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
|    *
|    *  An implementation of the DCCP protocol
|    *
|  + *  Copyrithg (c) 2007 Leandro Sales, Tommi Saviranta
|  + *
|  + *  This code has been developed by the Federal University of Campina Grande
|  + *  Embedded Systems and Pervasive Computing Lab and the Department of Computer
|  + *  Science at the University of Helsinki. For further information please see
|  + *  http://embedded.ufcg.edu.br/ <leandro@embedded.ufcg.edu.br>
|  + *  http://www.cs.helsinki.fi/ <wnd@iki.fi>
|  + *
|  + *  Copyrithg (c) 2005-7 Ian McDonald
|  + *
|    *  This code is based on code developed by the University of Waikato WAND
|    *  research group. For further information please see http://www.wand.net.nz/
|    *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
|  
|  

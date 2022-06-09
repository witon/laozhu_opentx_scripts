/** \file
 * \brief Gdk Clipboard Driver
 *
 * See Copyright Notice in cd.h
 */

#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include <gtk/gtk.h>

#include "cd.h"
#include "cd_private.h"
#include "cdclipbd.h"
#include "cdmf.h"
#include "cdmf_private.h"


static void cdkillcanvas(cdCtxCanvas *ctxcanvas)
{
  char* buffer;
  long dwSize;
  FILE* file;
  char filename[10240];
  cdCanvasMF* mfcanvas = (cdCanvasMF*)ctxcanvas;
  GtkClipboard *clipboard = (GtkClipboard*)mfcanvas->data;

  /* guardar antes de remover o canvas */
  strcpy(filename, mfcanvas->filename);

  cdkillcanvasMF(mfcanvas);

  file = fopen(filename, "r");
  fseek(file, 0, SEEK_END);
  dwSize = ftell(file); 
  fseek(file, 0, SEEK_SET);

  buffer = (char*)malloc(dwSize);
  fread(buffer, dwSize, 1, file);

  fclose(file);

  remove(filename);

  gtk_clipboard_set_text(clipboard, buffer, -1);

  free(buffer);
}

static int cdplay(cdCanvas* canvas, int xmin, int xmax, int ymin, int ymax, void *data)
{
  char filename[10240]; 
  int dwSize;
  FILE* file;
  GdkAtom* buffer;

  gtk_clipboard_wait_for_targets((GtkClipboard*)data, &buffer, &dwSize);
  if(!buffer)
    return CD_ERROR;

  if (!cdStrTmpFileName(filename))
    return CD_ERROR;

  file = fopen(filename, "w");
  fwrite(buffer, dwSize, 1, file);
  fclose(file);

  cdCanvasPlay(canvas, CD_METAFILE, xmin, xmax, ymin, ymax, filename);

  remove(filename);

  g_free(buffer);

  return CD_OK;
}

static void cdcreatecanvas(cdCanvas* canvas, void *data)
{
  char tmpPath[10240];
  char* str_data = (char*)data;
  GtkClipboard* clp = NULL;

  /* Init parameters */
  if (str_data == NULL) 
    return;

  sscanf(str_data, "%p", &clp); 

  if (!clp)
    return;

  str_data = strstr(str_data, " ");
  if (!str_data)
    return;

  str_data++;
  if (!cdStrTmpFileName(tmpPath))
    return;

  strcat(tmpPath, " ");
  strcat(tmpPath, str_data);

  cdcreatecanvasMF(canvas, tmpPath);
  if (!canvas->ctxcanvas)
    return;

  {
    cdCanvasMF* mfcanvas = (cdCanvasMF*)canvas->ctxcanvas;
    mfcanvas->data = clp;
  }
}

static void cdinittable(cdCanvas* canvas)
{
  cdinittableMF(canvas);
  canvas->cxKillCanvas = cdkillcanvas;
}


static cdContext cdClipboardContext =
{
  CD_CAP_ALL & ~(CD_CAP_GETIMAGERGB | CD_CAP_IMAGESRV | CD_CAP_FONTDIM | CD_CAP_TEXTSIZE ),  /* same as CD_MF */
  CD_CTX_DEVICE,
  cdcreatecanvas,  
  cdinittable,
  cdplay,          
  NULL
};

cdContext* cdContextClipboard(void)
{
  return &cdClipboardContext;
}



/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef CLOCKS_H
#define CLOCKS_H

#include <QtDeclarative/qdeclarative.h>
#include <QtDeclarative/QDeclarativeExtensionPlugin>

class clocks : public QDeclarativeExtensionPlugin
{
    Q_OBJECT

public:
    void registerTypes(const char *uri);
};

#endif // CLOCKS_H

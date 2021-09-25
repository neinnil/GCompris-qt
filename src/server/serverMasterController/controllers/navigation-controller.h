#ifndef NAVIGATIONCONTROLLER_H
#define NAVIGATIONCONTROLLER_H

#include <QObject>

#include <cm-lib_global.h>
#include <models/client.h>

namespace controllers {

class CMLIBSHARED_EXPORT NavigationController : public QObject
{
    Q_OBJECT

public:
    explicit NavigationController(QObject *parent = nullptr) :
        QObject(parent) { }

signals:
    void goManagePupilsView();
    void goCreateClientView();
    void goDashboardView();
    void goDevicesView();
    void goFindClientView();
    void goManageWorkPlanView();
    void goAddPupilsFromListDialog();
    void goRemovePupilsDialog();
    void goAddPupilDialog();
    void goAddPupilToGroupsDialog();
    void goRemovePupilToGroupsDialog();
};
}

#endif

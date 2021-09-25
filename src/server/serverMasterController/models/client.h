#ifndef CLIENT_H
#define CLIENT_H

#include <QObject>
#include <QtQml/QQmlListProperty>

#include <data/string-decorator.h>
#include <data/entity.h>
#include <data/entity-collection.h>
#include <models/address.h>
#include <models/contact.h>

namespace models {

class Client : public data::Entity
{
    Q_OBJECT
    Q_PROPERTY(data::StringDecorator *ui_reference MEMBER reference CONSTANT)
    Q_PROPERTY(data::StringDecorator *ui_name MEMBER name CONSTANT)
    Q_PROPERTY(models::Address *ui_supplyAddress MEMBER supplyAddress CONSTANT)
    Q_PROPERTY(models::Address *ui_billingAddress MEMBER billingAddress CONSTANT)
    Q_PROPERTY(QQmlListProperty<Contact> ui_contacts READ ui_contacts NOTIFY contactsChanged)

public:
    explicit Client(QObject *parent = nullptr);
    Client(QObject *parent, const QJsonObject &json);

    data::StringDecorator *reference { nullptr };
    data::StringDecorator *name { nullptr };
    Address *supplyAddress { nullptr };
    Address *billingAddress { nullptr };
    data::EntityCollection<Contact> *contacts { nullptr };

    QQmlListProperty<models::Contact> ui_contacts();

signals:
    void contactsChanged();
};

}

#endif

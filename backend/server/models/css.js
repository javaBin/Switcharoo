function attributes(DataTypes) {
    return {
        selector: {
            type: DataTypes.STRING,
            allowNull: false
        },
        property: {
            type: DataTypes.STRING,
            allowNull: false
        },
        value: {
            type: DataTypes.STRING,
            allowNull: false
        },
        type: {
            type: DataTypes.STRING,
            allowNull: false
        },
        title: {
            type: DataTypes.STRING,
            allowNull: false
        }
    };
}

module.exports = function(sequelize, DataTypes) {
    return sequelize.define('Css', attributes(DataTypes));
}
